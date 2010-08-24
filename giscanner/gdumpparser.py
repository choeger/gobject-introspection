# -*- Mode: Python -*-
# GObject-Introspection - a framework for introspecting GObject libraries
# Copyright (C) 2008  Johan Dahlin
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.
#

import os
import sys
import tempfile
import shutil
import subprocess
from xml.etree.cElementTree import parse

from . import ast
from . import glibast

# GParamFlags
G_PARAM_READABLE = 1 << 0
G_PARAM_WRITABLE = 1 << 1
G_PARAM_CONSTRUCT = 1 << 2
G_PARAM_CONSTRUCT_ONLY = 1 << 3
G_PARAM_LAX_VALIDATION = 1 << 4
G_PARAM_STATIC_NAME = 1 << 5
G_PARAM_STATIC_NICK = 1 << 6
G_PARAM_STATIC_BLURB = 1 << 7


class IntrospectionBinary(object):

    def __init__(self, args, tmpdir=None):
        self.args = args
        if tmpdir is None:
            self.tmpdir = tempfile.mkdtemp('', 'tmp-introspect')
        else:
            self.tmpdir = tmpdir


class Unresolved(object):

    def __init__(self, target):
        self.target = target


class UnknownTypeError(Exception):
    pass


class GDumpParser(object):

    def __init__(self, transformer):
        self._transformer = transformer
        self._namespace = transformer.namespace
        self._binary = None
        self._get_type_functions = []
        self._gtype_data = {}
        self._boxed_types = {}
        self._private_internal_types = {}

    # Public API

    def init_parse(self):
        """Do parsing steps that don't involve the introspection binary

        This does enough work that get_type_functions() can be called.

        """

        self._transformer.parse()

        # First pass: parsing
        for node in self._namespace.itervalues():
            if isinstance(node, ast.Function):
                self._initparse_function(node)
        if self._namespace.name == 'GObject':
            for node in self._namespace.itervalues():
                if isinstance(node, ast.Record):
                    self._initparse_gobject_record(node)

    def get_get_type_functions(self):
        return self._get_type_functions

    def set_introspection_binary(self, binary):
        self._binary = binary

    def parse(self):
        """Do remaining parsing steps requiring introspection binary"""

        # Get all the GObject data by passing our list of get_type
        # functions to the compiled binary, returning an XML blob.
        tree = self._execute_binary_get_tree()
        root = tree.getroot()
        for child in root:
            self._gtype_data[child.attrib['name']] = child
        for child in root:
            self._introspect_type(child)

        # Pair up boxed types and class records
        for name, boxed in self._boxed_types.iteritems():
            self._pair_boxed_type(boxed)
        for node in self._namespace.itervalues():
            if isinstance(node, (ast.Class, ast.Interface)):
                self._find_class_record(node)

        # Clear the _get_type functions out of the namespace;
        # Anyone who wants them can get them from the ast.Class/Interface/Boxed
        to_remove = []
        for name, node in self._namespace.iteritems():
            if isinstance(node, (ast.Class, ast.Interface, glibast.GLibBoxed,
                                 glibast.GLibEnum, glibast.GLibFlags)):
                get_type_name = node.get_type
                if get_type_name == 'intern':
                    continue
                assert get_type_name, node
                (ns, name) = self._transformer.split_csymbol(get_type_name)
                assert ns is self._namespace
                get_type_func = self._namespace.get(name)
                assert get_type_func, name
                to_remove.append(get_type_func)
        for node in to_remove:
            self._namespace.remove(node)

    # Helper functions

    def _execute_binary_get_tree(self):
        """Load the library (or executable), returning an XML
blob containing data gleaned from GObject's primitive introspection."""
        in_path = os.path.join(self._binary.tmpdir, 'types.txt')
        f = open(in_path, 'w')
        # TODO: Introspect GQuark functions
        for func in self._get_type_functions:
            f.write(func)
            f.write('\n')
        f.close()
        out_path = os.path.join(self._binary.tmpdir, 'dump.xml')

        args = []
        args.extend(self._binary.args)
        args.append('--introspect-dump=%s,%s' % (in_path, out_path))

        # Invoke the binary, having written our get_type functions to types.txt
        try:
            try:
                subprocess.check_call(args, stdout=sys.stdout, stderr=sys.stderr)
            except subprocess.CalledProcessError, e:
                # Clean up temporaries
                raise SystemExit(e)
            return parse(out_path)
        finally:
            shutil.rmtree(self._binary.tmpdir)

    def _create_gobject(self, node):
        type_name = 'G' + node.name
        if type_name == 'GObject':
            parent_gitype = None
            symbol = 'intern'
        elif type_name == 'GInitiallyUnowned':
            parent_gitype = ast.Type(target_giname='GObject.Object')
            symbol = 'g_initially_unowned_get_type'
        else:
            assert False
        gnode = glibast.GLibObject(node.name, parent_gitype, type_name, symbol, 'object', True)
        if type_name == 'GObject':
            gnode.fields.extend(node.fields)
        else:
            # http://bugzilla.gnome.org/show_bug.cgi?id=569408
            # GInitiallyUnowned is actually a typedef for GObject, but
            # that's not reflected in the GIR, where it appears as a
            # subclass (as it appears in the GType hierarchy).  So
            # what we do here is copy all of the GObject fields into
            # GInitiallyUnowned so that struct offset computation
            # works correctly.
            gnode.fields = self._namespace.get('Object').fields
        self._namespace.append(gnode, replace=True)

    # Parser

    def _initparse_function(self, func):
        symbol = func.symbol
        if symbol.startswith('_'):
            return
        elif symbol.endswith('_get_type'):
            self._initparse_get_type_function(func)

    def _initparse_get_type_function(self, func):
        if self._namespace.name == 'GLib':
            # No GObjects in GLib
            return False
        if (self._namespace.name == 'GObject' and
            func.symbol in ('g_object_get_type', 'g_initially_unowned_get_type')):
            # We handle these internally, see _create_gobject
            return True
        if func.parameters:
            return False
        # GType *_get_type(void)
        rettype = func.retval.type
        if not (rettype.is_equiv(ast.TYPE_GTYPE)
                or rettype.target_giname == 'Gtk.Type'):
            self._transformer.log_warning("function returns '%r', not a GType"
                                          % (func.retval.type, ))
            return False

        self._get_type_functions.append(func.symbol)
        return True

    def _initparse_gobject_record(self, record):
        # Special handling for when we're parsing GObject
        internal_names = ("Object", 'InitiallyUnowned')
        if record.name in internal_names:
            self._create_gobject(record)
            return
        if record.name == 'InitiallyUnownedClass':
            record.fields = self._namespace.get('ObjectClass').fields
        self._namespace.append(record, replace=True)

    # Introspection over the data we get from the dynamic
    # GObject/GType system out of the binary

    def _introspect_type(self, xmlnode):
        if xmlnode.tag in ('enum', 'flags'):
            self._introspect_enum(xmlnode)
        elif xmlnode.tag == 'class':
            self._introspect_object(xmlnode)
        elif xmlnode.tag == 'interface':
            self._introspect_interface(xmlnode)
        elif xmlnode.tag == 'boxed':
            self._introspect_boxed(xmlnode)
        elif xmlnode.tag == 'fundamental':
            self._introspect_fundamental(xmlnode)
        else:
            raise ValueError("Unhandled introspection XML tag %s", xmlnode.tag)

    def _introspect_enum(self, node):
        members = []
        for member in node.findall('member'):
            # Keep the name closer to what we'd take from C by default;
            # see http://bugzilla.gnome.org/show_bug.cgi?id=575613
            name = member.attrib['nick'].replace('-', '_')
            members.append(glibast.GLibEnumMember(name,
                                          member.attrib['value'],
                                          member.attrib['name'],
                                          member.attrib['nick']))

        klass = (glibast.GLibFlags if node.tag == 'flags' else glibast.GLibEnum)
        type_name = node.attrib['name']
        enum_name = self._transformer.strip_identifier_or_warn(type_name, fatal=True)
        node = klass(enum_name, type_name, members, node.attrib['get-type'])
        self._namespace.append(node, replace=True)

    def _split_type_and_symbol_prefix(self, xmlnode):
        """Infer the C symbol prefix from the _get_type function."""
        get_type = xmlnode.attrib['get-type']
        (ns, name) = self._transformer.split_csymbol(get_type)
        assert ns is self._namespace
        assert name.endswith('_get_type')
        return (get_type, name[:-len('_get_type')])

    def _introspect_object(self, xmlnode):
        type_name = xmlnode.attrib['name']
        # We handle this specially above; in 2.16 and below there
        # was no g_object_get_type, for later versions we need
        # to skip it
        if type_name == 'GObject':
            return
        is_abstract = bool(xmlnode.attrib.get('abstract', False))
        (get_type, c_symbol_prefix) = self._split_type_and_symbol_prefix(xmlnode)
        node = glibast.GLibObject(
            self._transformer.strip_identifier_or_warn(type_name, fatal=True),
            None,
            type_name,
            get_type, c_symbol_prefix, is_abstract)
        self._parse_parents(xmlnode, node)
        self._introspect_properties(node, xmlnode)
        self._introspect_signals(node, xmlnode)
        self._introspect_implemented_interfaces(node, xmlnode)

        self._add_record_fields(node)
        self._namespace.append(node, replace=True)

    def _introspect_interface(self, xmlnode):
        type_name = xmlnode.attrib['name']
        (get_type, c_symbol_prefix) = self._split_type_and_symbol_prefix(xmlnode)
        node = glibast.GLibInterface(
            self._transformer.strip_identifier_or_warn(type_name, fatal=True),
            None,
            type_name, get_type, c_symbol_prefix)
        self._introspect_properties(node, xmlnode)
        self._introspect_signals(node, xmlnode)
        for child in xmlnode.findall('prerequisite'):
            name = child.attrib['name']
            prereq = self._transformer.create_type_from_user_string(name)
            node.prerequisites.append(prereq)
        # GtkFileChooserEmbed is an example of a private interface, we
        # just filter them out
        if xmlnode.attrib['get-type'].startswith('_'):
            self._private_internal_types[type_name] = node
        else:
            self._namespace.append(node, replace=True)

    def _introspect_boxed(self, xmlnode):
        type_name = xmlnode.attrib['name']
        # This one doesn't go in the main namespace; we associate it with
        # the struct or union
        (get_type, c_symbol_prefix) = self._split_type_and_symbol_prefix(xmlnode)
        node = glibast.GLibBoxed(type_name, get_type, c_symbol_prefix)
        self._boxed_types[node.type_name] = node

    def _introspect_implemented_interfaces(self, node, xmlnode):
        gt_interfaces = []
        for interface in xmlnode.findall('implements'):
            gitype = self._transformer.create_type_from_user_string(interface.attrib['name'])
            gt_interfaces.append(gitype)
        node.interfaces = gt_interfaces

    def _introspect_properties(self, node, xmlnode):
        for pspec in xmlnode.findall('property'):
            ctype = pspec.attrib['type']
            flags = int(pspec.attrib['flags'])
            readable = (flags & G_PARAM_READABLE) != 0
            writable = (flags & G_PARAM_WRITABLE) != 0
            construct = (flags & G_PARAM_CONSTRUCT) != 0
            construct_only = (flags & G_PARAM_CONSTRUCT_ONLY) != 0
            node.properties.append(ast.Property(
                pspec.attrib['name'],
                self._transformer.create_type_from_user_string(ctype),
                readable, writable, construct, construct_only,
                ctype,
                ))
        node.properties = node.properties

    def _introspect_signals(self, node, xmlnode):
        for signal_info in xmlnode.findall('signal'):
            rctype = signal_info.attrib['return']
            rtype = self._transformer.create_type_from_user_string(rctype)
            return_ = ast.Return(rtype)
            parameters = []
            for i, parameter in enumerate(signal_info.findall('param')):
                if i == 0:
                    argname = 'object'
                else:
                    argname = 'p%s' % (i-1, )
                pctype = parameter.attrib['type']
                ptype = self._transformer.create_type_from_user_string(pctype)
                param = ast.Parameter(argname, ptype)
                param.transfer = ast.PARAM_TRANSFER_NONE
                parameters.append(param)
            signal = glibast.GLibSignal(signal_info.attrib['name'], return_, parameters)
            node.signals.append(signal)
        node.signals = node.signals

    def _parse_parents(self, xmlnode, node):
        if 'parents' in xmlnode.attrib:
            parent_types = map(lambda s: self._transformer.create_type_from_user_string(s),
                               xmlnode.attrib['parents'].split(','))
        else:
            parent_types = []
        node.parent_chain = parent_types

    def _introspect_fundamental(self, xmlnode):
        # We only care about types that can be instantiatable, other
        # fundamental types such as the Clutter.Fixed/CoglFixed registers
        # are not yet interesting from an introspection perspective and
        # are ignored
        if not xmlnode.attrib.get('instantiatable', False):
            return

        type_name = xmlnode.attrib['name']
        is_abstract = bool(xmlnode.attrib.get('abstract', False))
        (get_type, c_symbol_prefix) = self._split_type_and_symbol_prefix(xmlnode)
        node = glibast.GLibObject(
            self._transformer.strip_identifier_or_warn(type_name, fatal=True),
            None,
            type_name,
            get_type, c_symbol_prefix, is_abstract)
        self._parse_parents(xmlnode, node)
        node.fundamental = True
        self._introspect_implemented_interfaces(node, xmlnode)

        self._add_record_fields(node)
        self._namespace.append(node, replace=True)

    def _add_record_fields(self, node):
        # add record fields
        record = self._namespace.get(node.name)
        if not isinstance(record, ast.Record):
            return
        node.fields = record.fields
        for field in node.fields:
            if isinstance(field, ast.Field):
                # Object instance fields are assumed to be read-only
                # (see also _find_class_record and transformer.py)
                field.writable = False

    def _pair_boxed_type(self, boxed):
        name = self._transformer.strip_identifier_or_warn(boxed.type_name, fatal=True)
        pair_node = self._namespace.get(name)
        if not pair_node:
            boxed_item = glibast.GLibBoxedOther(name, boxed.type_name,
                                        boxed.get_type,
                                        boxed.c_symbol_prefix)
        elif isinstance(pair_node, ast.Record):
            boxed_item = glibast.GLibBoxedStruct(pair_node.name, boxed.type_name,
                                         boxed.get_type,
                                         boxed.c_symbol_prefix)
            boxed_item.inherit_file_positions(pair_node)
            boxed_item.fields = pair_node.fields
        elif isinstance(pair_node, ast.Union):
            boxed_item = glibast.GLibBoxedUnion(pair_node.name, boxed.type_name,
                                        boxed.get_type,
                                        boxed.c_symbol_prefix)
            boxed_item.inherit_file_positions(pair_node)
            boxed_item.fields = pair_node.fields
        else:
            return False
        self._namespace.append(boxed_item, replace=True)

    def _strip_class_suffix(self, name):
        if (name.endswith('Class') or
            name.endswith('Iface')):
            return name[:-5]
        elif name.endswith('Interface'):
            return name[:-9]
        else:
            return None

    def _find_class_record(self, cls):
        pair_record = None
        if isinstance(cls, ast.Class):
            pair_record = self._namespace.get(cls.name + 'Class')
        else:
            for suffix in ('Iface', 'Interface'):
                pair_record = self._namespace.get(cls.name + suffix)
                if pair_record:
                    break
        if not (pair_record and isinstance(pair_record, ast.Record)):
            return

        gclass_struct = glibast.GLibRecord.from_record(pair_record)
        self._namespace.append(gclass_struct, replace=True)
        cls.glib_type_struct = gclass_struct.create_type()
        cls.inherit_file_positions(pair_record)
        gclass_struct.is_gtype_struct_for = cls.create_type()