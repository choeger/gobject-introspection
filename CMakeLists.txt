project(gobject-introspection C)
# we need to be up to date
CMAKE_MINIMUM_REQUIRED(VERSION 2.8.8 FATAL_ERROR)

set(gi_major_version, 1)
set(gi_minor_version, 33)
set(gi_micro_version, 0)
set(gi_version "${gi_major_version}.${gi_minor_version}.${gi_micro_version}")

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# autoconf emulation

set(INSTALL_SBINDIR ${CMAKE_INSTALL_PREFIX}/sbin)
set(INSTALL_DATADIR ${CMAKE_INSTALL_PREFIX}/share)

#### Directory to install the libexec binaries
set(GOBJECT_INTROSPECTION_LIBDIR ${INSTALL_SBINDIR})

#### Directory to install the gir files
set(GIR_SUFFIX "gir-1.0")
set(GIR_DIR "${INSTALL_DATADIR}/${GIR_SUFFIX}")

include (CheckTypeSize) 
check_type_size(char SIZEOF_CHAR)
check_type_size(short SIZEOF_SHORT)
check_type_size(int SIZEOF_INT)
check_type_size(long SIZEOF_LONG)

set(SHLIB_SUFFIX ${CMAKE_SHARED_LIBRARY_SUFFIX})

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h)
include_directories(${CMAKE_CURRENT_BINARY_DIR})
add_definitions(-DHAVE_CONFIG_H)

#dependencies
find_package(GLIB REQUIRED)
find_package(FFI REQUIRED)

# Find Python executable  
find_package(PythonInterp REQUIRED)
find_package(PythonLibs REQUIRED)

if(NOT PYTHONLIBS_FOUND OR NOT PYTHON_EXECUTABLE)
  message(SEND_ERROR "You need Python to build the dbus python bindings")
endif(NOT PYTHONLIBS_FOUND OR NOT PYTHON_EXECUTABLE)

# The code below prints the Python extension for the current system
set(get_python_suffix "import imp ; print(list(filter(lambda s : s[1] == 'rb' and s[0][0] == '.', imp.get_suffixes()))[0][0])")

execute_process(
  COMMAND ${PYTHON_EXECUTABLE} -c "${get_python_suffix}"
  OUTPUT_VARIABLE _modsuffix
)
string(REPLACE "\n" "" _modsuffix ${_modsuffix}) 
message(STATUS "Python module suffix is: ${_modsuffix}")

# The code below returns the site-packages directory for the current system
set(get_site_package_dir "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
execute_process(
  COMMAND ${PYTHON_EXECUTABLE} -c "${get_site_package_dir}"
  OUTPUT_VARIABLE site_pkg
)
string(REPLACE "\n" "" site_pkg ${site_pkg}) 
message(STATUS "Python module path is: ${site_pkg}")

include(cmph.cmake)
include(girepository.cmake)
include(tools.cmake)
include(giscanner.cmake)
include(gir.cmake)

