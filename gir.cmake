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
	
file(GLOB glib_includes ${GLIB_INCLUDE_DIR}/glib/*.h)
set(GLib-2.0_FILES 
		${GLIB_INCLUDE_DIR}/gobject/glib-types.h 
		${GLIB_LIBRARY_DIR}/glib-2.0/include/glibconfig.h 
		${GLIB_INCLUDE_DIR}/gobject/glib-types.h 
		${CMAKE_CURRENT_SOURCE_DIR}/gir/glib-2.0.c 
		${glib_includes})
set(GLib-2.0_LIBS ":${GLIB_LIBRARY}" ":${GOBJECT_LIBRARY}") #: prefix is probably not portable ...
set(GLib-2.0_SCANNERFLAGS 
			--external-library
            --reparse-validate
            --identifier-prefix=G
            --symbol-prefix=g
            --symbol-prefix=glib
            --c-include="glib.h"
)
set(GLib-2.0_PACKAGES glib-2.0)

find_path(intl libintl.h)

set(GLib-2.0_CFLAGS
            -I${GLIB_INCLUDE_DIR}
            -I${GLIB_LIBDIR}/glib-2.0/include
            -DGETTEXT_PACKAGE=Dummy
            -DGLIB_COMPILATION
            -D__G_I18N_LIB_H__
			-I${intl}
)

target_scan_gir(GLib-2.0)

set(GObject-2.0_FILES gir/gobject-2.0.c)
		
file(GLOB gobject_includes ${GLIB_INCLUDE_DIR}/gobject/*.h)
set(GObject-2.0_FILES 
		${CMAKE_CURRENT_SOURCE_DIR}/gir/gobject-2.0.c
		${glib_includes})
set(GObject-2.0_LIBS ":${GOBJECT_LIBRARY}") #: prefix is probably not portable ...
set(GObject-2.0_SCANNERFLAGS 
			--external-library
            --reparse-validate
            --identifier-prefix=G
            --symbol-prefix=g
            --symbol-prefix=glib
            --c-include="glib-object.h"
)
set(GLib-2.0_CFLAGS
            -DGOBJECT_COMPILATION
            -I${GLIB_INCLUDE_DIR}
            -I${GLIB_LIBDIR}/glib-2.0/include
)
set(GObject-2.0_PACKAGES gobject-2.0)
set(GObject-2.0_INCLUDES GLib-2.0)

target_scan_gir(GObject-2.0)

list(APPEND DBusGLib-1.0_DEPENDENCIES "${CMAKE_CURRENT_BINARY_DIR}/GObject-2.0.gir")
target_add_gir(static_gir "gir/" ${GLib-2.0_gir} ${static_gir_sources})
