find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)

BISON_TARGET(scannerparser giscanner/scannerparser.y ${CMAKE_CURRENT_BINARY_DIR}/scannerparser.c)
FLEX_TARGET(scannerlexer giscanner/scannerlexer.l ${CMAKE_CURRENT_BINARY_DIR}/scannerlexer.c)
ADD_FLEX_BISON_DEPENDENCY(scannerlexer scannerparser)

include_directories(giscanner ${CMAKE_CURRENT_BINARY_DIR} ${PYTHON_INCLUDE_DIRS})

set(giscanner_sources
	"giscanner/sourcescanner.c"
	"giscanner/sourcescanner.h"
	${BISON_scannerparser_OUTPUTS}
	${FLEX_scannerlexer_OUTPUTS}
	"giscanner/grealpath.h"	
	)
	
add_library(giscanner SHARED ${giscanner_sources})
target_link_libraries(giscanner ${GLIB_LIBRARIES})

add_definitions(-DUSE_DL_IMPORT -Wl,--no-undefined -save-temps -Wp,-dD)
add_library(_giscanner SHARED "giscanner/giscannermodule.c")

target_link_libraries(_giscanner giscanner ${PYTHON_LIBRARIES} ${GLIB_LIBRARIES})
message(STATUS "suffix: ${_modsuffix}")
set_target_properties(_giscanner
 PROPERTIES
   PREFIX "" # There is no prefix even on UNIXes
   SUFFIX "${_modsuffix}" # The extension got from Python libraries
)

set (giscanner_py_source
	"giscanner/__init__.py"
	"giscanner/annotationmain.py"
	"giscanner/annotationparser.py"
	"giscanner/annotationpatterns.py"
	"giscanner/ast.py"
	"giscanner/cachestore.py"
	"giscanner/codegen.py"
	"giscanner/docmain.py"
	"giscanner/dumper.py"
	"giscanner/introspectablepass.py"
	"giscanner/girparser.py"
	"giscanner/girwriter.py"
	"giscanner/gdumpparser.py"
	"giscanner/libtoolimporter.py"
	"giscanner/odict.py"
	"giscanner/mallardwriter.py"
	"giscanner/mallard-C-class.tmpl"
	"giscanner/mallard-C-default.tmpl"
	"giscanner/mallard-C-enum.tmpl"
	"giscanner/mallard-C-function.tmpl"
	"giscanner/mallard-C-namespace.tmpl"
	"giscanner/mallard-C-property.tmpl"
	"giscanner/mallard-C-record.tmpl"
	"giscanner/mallard-C-signal.tmpl"
	"giscanner/mallard-C-vfunc.tmpl"
	"giscanner/mallard-Python-class.tmpl"
	"giscanner/mallard-Python-default.tmpl"
	"giscanner/mallard-Python-enum.tmpl"
	"giscanner/mallard-Python-function.tmpl"
	"giscanner/mallard-Python-namespace.tmpl"
	"giscanner/mallard-Python-property.tmpl"
	"giscanner/mallard-Python-record.tmpl"
	"giscanner/mallard-Python-signal.tmpl"
	"giscanner/mallard-Python-vfunc.tmpl"
	"giscanner/maintransformer.py"
	"giscanner/message.py"
	"giscanner/shlibs.py"
	"giscanner/sourcescanner.py"
	"giscanner/testcodegen.py"
	"giscanner/transformer.py"
	"giscanner/utils.py"
	"giscanner/xmlwriter.py"
	"giscanner/scannermain.py"
	)

set (giscanner_main_py_source
	"giscanner/scannermain.py"
	)
	
file(INSTALL ${giscanner_main_py_source} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
file(INSTALL ${giscanner_py_source} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/giscanner)