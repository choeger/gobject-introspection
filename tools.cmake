set(g-ir-compiler_sources tools/compiler.c)
add_executable(g-ir-compiler ${g-ir-compiler_sources})
target_link_libraries(g-ir-compiler girepository_internals girepository_1_0)

set(g-ir-generate_sources tools/generate.c)
add_executable(g-ir-generate ${g-ir-compiler_sources})
target_link_libraries(g-ir-generate girepository_internals girepository_1_0)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/tools/g-ir-annotation-tool.in ${CMAKE_CURRENT_BINARY_DIR}/g-ir-annotation-tool.py)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/tools/g-ir-scanner.in ${CMAKE_CURRENT_BINARY_DIR}/g-ir-scanner.py)

set(scanner_py ${CMAKE_CURRENT_BINARY_DIR}/g-ir-scanner.py)
set(annotation_tool_py ${CMAKE_CURRENT_BINARY_DIR}/g-ir-annotation-tool.py)
