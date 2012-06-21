set(g-ir-compiler_sources tools/compiler.c)
add_executable(g-ir-compiler ${g-ir-compiler_sources})
target_link_libraries(g-ir-compiler girepository_internals girepository_1_0)

set(g-ir-generate_sources tools/generate.c)
add_executable(g-ir-generate ${g-ir-compiler_sources})
target_link_libraries(g-ir-generate girepository_internals girepository_1_0)
