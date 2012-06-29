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
	# Namespace and Version is either fetched from the gir filename
	# or the _NAMESPACE/_VERSION variable combo
	if(${name}_NAMESPACE)
	    set(namespace ${${name}_NAMESPACE})
	else(${name}_NAMESPACE)
		string(REPLACE "-" ";" name_list ${name})
		list(GET name_list 0 namespace)
	endif(${name}_NAMESPACE)
	
	if(${name}_VERSION)
	    set(namespace ${${name}_VERSION})
	else(${name}_VERSION)
		string(REPLACE "-" ";" name_list ${name})
		list(GET name_list -1 version)
	endif(${name}_VERSION)

	# _PROGRAM is an optional variable which needs it's own --program argument
	if(${name}_PROGRAM)
	    set(program --program=${${name}_PROGRAM})
    endif(${name}_PROGRAM)

	set(libraries)
	# Variables which provides a list of things	
	foreach(lib ${${name}_LIBS})
	    list(APPEND libraries "--library=${lib}")
	endforeach(lib ${${name}_LIBS})

	foreach(pkg ${${name}_PACKAGES})
	    list(APPEND packages "--pkg=${pkg}")
	endforeach(pkg ${${name}_PACKAGES})

	foreach(incl ${${name}_INCLUDES})
	    list(APPEND includes "--include=${incl}")
	endforeach(incl ${${name}_INCLUDES})

	foreach(exp ${${name}_EXPORT_PACKAGES})
	    list(APPEND export_packages "--pkg-export=${exp}")
	endforeach(exp ${${name}_EXPORT_PACKAGES})

    add_custom_command(
	  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${name}.gir"
	  COMMAND ${PYTHON_EXECUTABLE} ARGS g-ir-scanner.py --namespace=${namespace}
		--nsversion=${version} 	${packages} ${includes} ${export_packages} ${program} ${libraries} 
		${${name}_SCANNERFLAGS} ${${name}_CFLAGS} ${${name}_LDFLAGS} ${${name}_FILES} "--output=${CMAKE_CURRENT_BINARY_DIR}/${name}.gir"
	  DEPENDS ${${name}_FILES}
	  COMMENT "Compiling gir: ${name}"
	)
	
	set(${name}_gir "${CMAKE_CURRENT_BINARY_DIR}/${name}.gir")
endmacro(target_scan_gir name)