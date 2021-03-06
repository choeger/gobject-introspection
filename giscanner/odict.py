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

"""odict - an ordered dictionary"""

from collections import MutableMapping


class odict(MutableMapping):

    def __init__(self):
        self._items = {}
        self._keys = []

    def __setitem__(self, key, value):
        if key not in self._items:
            self._keys.append(key)
        self._items[key] = value

    def __getitem__(self, key):
        return self._items[key]

    def __delitem__(self, key):
        del self._items[key]
        self._keys.remove(key)

    def keys(self):
        return self._keys[:]
