cmake_minimum_required(VERSION 3.22)

option(QUEST "Build for quest" ON)

# Targets
if(QUEST)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/targets/quest.cmake)
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/toolchain.cmake)

# Uncomment to enable using vcpkg packages
# include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/vcpkg.cmake)


project(#{id}
	VERSION ${QPM_TOOLCHAIN_PACKAGE_VERSION})

# Globals
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

set(SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)

add_compile_options(-frtti -fexceptions -fvisibility=hidden -fPIE -fPIC)

if(${CMAKE_BUILD_TYPE} STREQUAL "RELEASE" OR ${CMAKE_BUILD_TYPE} STREQUAL "RelWithDebInfo" OR ${CMAKE_BUILD_TYPE} STREQUAL "MinSizeRel")
    # Better optimizations
    add_compile_options(-O3)

    # LTO
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
    add_compile_options(-flto)
endif()

if(${CMAKE_BUILD_TYPE} STREQUAL "DEBUG" OR ${CMAKE_BUILD_TYPE} STREQUAL "RelWithDebInfo")
    add_compile_options(-g)
endif()

# recursively get all src files
file(GLOB_RECURSE cpp_file_list ${SOURCE_DIR}/*.cpp)
file(GLOB_RECURSE c_file_list ${SOURCE_DIR}/*.c)

add_library(
    ${CMAKE_PROJECT_NAME}
    SHARED
    ${cpp_file_list}
    ${c_file_list}
)

add_compile_definitions(MOD_ID="${CMAKE_PROJECT_NAME}")
add_compile_definitions(VERSION="${CMAKE_PROJECT_VERSION}")

# for inline hook
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE -llog)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${INCLUDE_DIR})

# beatsaber hook inline hook
file(GLOB_RECURSE src_inline_hook_beatsaber_hook_local_extra_c ${EXTERN_DIR}/includes/beatsaber-hook/shared/inline-hook/*.c)
file(GLOB_RECURSE src_inline_hook_beatsaber_hook_local_extra_cpp ${EXTERN_DIR}/includes/beatsaber-hook/shared/inline-hook/*.cpp)

target_sources(${CMAKE_PROJECT_NAME} PRIVATE ${src_inline_hook_beatsaber_hook_local_extra_c})
target_sources(${CMAKE_PROJECT_NAME} PRIVATE ${src_inline_hook_beatsaber_hook_local_extra_cpp})

# Post build
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/strip.cmake)
