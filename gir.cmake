set(static_gir_sources
        "gir/DBus-1.0.gir"
        "gir/DBusGLib-1.0.gir"
        "gir/fontconfig-2.0.gir"
        "gir/freetype2-2.0.gir"
        "gir/GL-1.0.gir"
        "gir/libxml2-2.0.gir"
        "gir/xft-2.0.gir"
        "gir/xlib-2.0.gir"
        "gir/xfixes-4.0.gir"
        "gir/xrandr-1.3.gir"
	)

include(introspection.cmake)
	
file(GLOB glib_includes $(GLIB_INCLUDEDIR)/glib/*.h)
set(GLib-2.0_FILES $(GLIB_LIBDIR)/glib-2.0/include/glibconfig.h $(GLIB_INCLUDEDIR)/gobject/glib-types.h gir/glib-2.0.c ${glib_includes})
target_scan_gir(GLib-2.0)

set(GObject-2.0_FILES gir/gobject-2.0.c)
target_scan_gir(GObject-2.0)
		
target_add_gir(static_gir "gir/" GObject-2.0.gir GLib-2.0.gir ${static_gir_sources})

