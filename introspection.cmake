macro(target_add_gir name dir)
  set(infiles ${ARGN})
  set(outfiles)
	
  foreach(gir IN LISTS infiles)
	message(STATUS "Now on ${gir}")
	get_filename_component(f "${gir}" ABSOLUTE)
	get_filename_component(include_dir "${f}" PATH)	
    get_filename_component(base ${f} NAME_WE)
    add_custom_command(
	  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${base}.typelib"
	  COMMAND g-ir-compiler ARGS ${f} -o "${CMAKE_CURRENT_BINARY_DIR}/${base}.typelib" --includedir=${include_dir}
	  MAIN_DEPENDENCY ${f}
	  COMMENT "Compiling gir: ${base}"
	)
	list(APPEND outfiles "${CMAKE_CURRENT_BINARY_DIR}/${base}.typelib")
  endforeach(gir)
  
  add_custom_target(${name}_gir_compile ALL DEPENDS ${outfiles} COMMENT "Compiling typelibs of ${name}")
endmacro(target_add_gir name sources)

macro(target_scan_gir name)
    add_custom_command(
	  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${name}.gir"
	  COMMAND ${PYTHON} ARGS g-ir-scanner.py ${${name}_FILES}
	  DEPENDS ${${name}_FILES}
	  COMMENT "Compiling gir: ${name}"
	)
endmacro(target_scan_gir name)