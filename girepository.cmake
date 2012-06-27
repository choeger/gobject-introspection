set(girepodir "gobject-introspection-1.0/")

set(girepo_headers "girepository/giarginfo.h"
	"girepository/gibaseinfo.h"
	"girepository/gicallableinfo.h"
	"girepository/giconstantinfo.h"
	"girepository/gienuminfo.h"
	"girepository/gifieldinfo.h"
	"girepository/gifunctioninfo.h"
	"girepository/giinterfaceinfo.h"
	"girepository/giobjectinfo.h"
	"girepository/gipropertyinfo.h"
	"girepository/giregisteredtypeinfo.h"
	"girepository/girepository.h"
	"girepository/girffi.h"
	"girepository/gisignalinfo.h"
	"girepository/gistructinfo.h"
	"girepository/gitypeinfo.h"
	"girepository/gitypelib.h"
	"girepository/gitypes.h"
	"girepository/giunioninfo.h"
	"girepository/givfuncinfo.h"
	)

include_directories(girepository)
	
set(girepository_gthash_sources "girepository/gthash.c")
add_library(girepository_gthash SHARED ${girepository_gthash_sources})
target_link_libraries(girepository_gthash cmph ${GLIB_LIBRARIES})

set(girepository_sources
	"girepository/gdump.c"
	"girepository/giarginfo.c"
	"girepository/gibaseinfo.c"
	"girepository/gicallableinfo.c"
	"girepository/giconstantinfo.c"
	"girepository/gienuminfo.c"
	"girepository/gifieldinfo.c"
	"girepository/gifunctioninfo.c"
	"girepository/ginvoke.c"
	"girepository/giinterfaceinfo.c"
	"girepository/giobjectinfo.c"
	"girepository/gipropertyinfo.c"
	"girepository/giregisteredtypeinfo.c"
	"girepository/girepository.c"
	"girepository/girepository-private.h"
	"girepository/girffi.c"
	"girepository/girffi.h"
	"girepository/gisignalinfo.c"
	"girepository/gistructinfo.c"
	"girepository/gitypeinfo.c"
	"girepository/gitypelib.c"
	"girepository/gitypelib-internal.h"
	"girepository/glib-compat.h"
	"girepository/giunioninfo.c"
	"girepository/givfuncinfo.c"
	)

add_definitions(-DG_IREPOSITORY_COMPILATION)
add_library(girepository_1_0 SHARED ${girepository_sources})
set_target_properties(girepository_1_0 PROPERTIES LINK_FLAGS -Wl,-no-undefined)
target_link_libraries(girepository_1_0 girepository_gthash ${GLIB_LIBRARIES} ${FFI_LIBRARIES})

set(girepository_internals_sources 
	"girepository/girmodule.c"
	"girepository/girmodule.h"
	"girepository/girnode.c"
	"girepository/girnode.h"
	"girepository/giroffsets.c"
	"girepository/girparser.c"
	"girepository/girparser.h"
	"girepository/girwriter.c"
	"girepository/girwriter.h"
	)

include_directories(${FFI_INCLUDE_DIRS})
	
add_library(girepository_internals SHARED ${girepository_internals_sources})
set_target_properties(girepository_internals PROPERTIES LINK_FLAGS "-Wl,-no-undefined -Wl,--enable-runtime-pseudo-reloc")
target_link_libraries(girepository_internals girepository_gthash girepository_1_0 ${GLIB_LIBRARIES} ${FFI_LIBRARIES})

set_target_properties(girepository_1_0 PROPERTIES PUBLIC_HEADER "${girepo_headers}")

install(TARGETS girepository_1_0 girepository_gthash
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  PUBLIC_HEADER DESTINATION "include/${girepodir}"
)
