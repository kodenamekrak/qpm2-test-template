include_guard()

# Run at end to link with project
cmake_language(DEFER DIRECTORY ${CMAKE_SOURCE_DIR} CALL _setup_linux_strip_project())

function(_setup_linux_strip_project)
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux" OR CMAKE_SYSTEM_NAME STREQUAL "Android")
        message("Enabling Stripping")

        # Strip debug symbols
        add_custom_command(TARGET ${CMAKE_PROJECT_NAME} POST_BUILD
            COMMAND ${CMAKE_STRIP} -d --strip-all
            "lib${CMAKE_PROJECT_NAME}.so" -o "stripped_lib${CMAKE_PROJECT_NAME}.so"
            COMMENT "Strip debug symbols done on final binary.")

        add_custom_command(TARGET ${CMAKE_PROJECT_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory debug
            COMMENT "Make directory for debug symbols"
        )
        add_custom_command(TARGET ${CMAKE_PROJECT_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E rename lib${CMAKE_PROJECT_NAME}.so debug/lib${CMAKE_PROJECT_NAME}.so
            COMMENT "Rename the lib to debug_ since it has debug symbols"
        )

        # strip debug symbols from the .so and all dependencies
        add_custom_command(TARGET ${CMAKE_PROJECT_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E rename stripped_lib${CMAKE_PROJECT_NAME}.so lib${CMAKE_PROJECT_NAME}.so
            COMMENT "Rename the stripped lib to regular"
        )
    endif()
endfunction(_setup_linux_strip_project)
