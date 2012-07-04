find_package(PkgConfig)
if (PKG_CONFIG_FOUND)
  pkg_check_modules(GLIB_PKG glib-2.0)
endif (PKG_CONFIG_FOUND)

if (GLIB_PKG_FOUND)
    find_path(GLIB_INCLUDE_DIR  NAMES glib.h PATH_SUFFIXES glib-2.0
       PATHS
       ${GLIB_PKG_INCLUDE_DIRS}
       /usr/include/glib-2.0
       /usr/include
       /usr/local/include
    )
    find_path(GLIB_CONFIG_INCLUDE_DIR NAMES glibconfig.h PATHS ${GLIB_PKG_LIBDIR} PATH_SUFFIXES glib-2.0/include)

    find_library(GLIB_LIBRARIES NAMES glib-2.0
       PATHS
       ${GLIB_PKG_LIBRARY_DIRS}
       /usr/lib
       /usr/local/lib
    )

else (GLIB_PKG_FOUND)
    # Find Glib even if pkg-config is not working (eg. cross compiling to Windows)
    find_library(GLIB_LIBRARY NAMES glib-2.0)
	find_library(GOBJECT_LIBRARY NAMES gobject-2.0)
	find_library(GMODULE_LIBRARY NAMES gmodule-2.0)
	find_library(GIO_LIBRARY NAMES gio-2.0)
		
    get_filename_component(GLIB_LIBRARY_DIR ${GLIB_LIBRARY} PATH)

    find_path(GLIB_INCLUDE_DIR NAMES glib.h PATH_SUFFIXES glib-2.0)
    find_path(GLIB_CONFIG_INCLUDE_DIR NAMES glibconfig.h PATHS ${GLIB_LIBRARY_DIR} PATH_SUFFIXES glib-2.0/include)
    
endif (GLIB_PKG_FOUND)

if (GLIB_INCLUDE_DIR AND GLIB_CONFIG_INCLUDE_DIR AND GLIB_LIBRARY AND GOBJECT_LIBRARY AND GMODULE_LIBRARY AND GIO_LIBRARY)
    set(GLIB_INCLUDE_DIRS ${GLIB_INCLUDE_DIR} ${GLIB_CONFIG_INCLUDE_DIR})
	set(GLIB_LIBRARIES ${GLIB_LIBRARY} ${GOBJECT_LIBRARY} ${GMODULE_LIBRARY} ${GIO_LIBRARY})
	set(GLIB_LIBRARY_DIRS ${GLIB_LIBRARY_DIR})
    set(GLIB_FOUND TRUE)
else (GLIB_INCLUDE_DIR AND GLIB_CONFIG_INCLUDE_DIR AND GLIB_LIBRARY AND GOBJECT_LIBRARY AND GMODULE_LIBRARY AND GIO_LIBRARY)
	set(GLIB_FOUND FALSE)
endif (GLIB_INCLUDE_DIR AND GLIB_CONFIG_INCLUDE_DIR AND GLIB_LIBRARY AND GOBJECT_LIBRARY AND GMODULE_LIBRARY AND GIO_LIBRARY)

IF( GLIB_FOUND )
    MESSAGE( STATUS "Found glib: ${GLIB_INCLUDE_DIRS} ${GLIB_LIBRARIES}" )
    ELSE( GLIB_FOUND )
    IF( GLIB_FIND_REQUIRED )
    	MESSAGE( FATAL_ERROR "Could not find glib" )
    ENDIF( GLIB_FIND_REQUIRED )
ENDIF( GLIB_FOUND )

mark_as_advanced(GLIB_INCLUDE_DIR GLIB_CONFIG_INCLUDE_DIR GLIB_INCLUDE_DIRS GLIB_LIBRARIES)