#
# The main config file for ezImGui
#
cmake_minimum_required(VERSION 3.20)
project(ezImGui)

option(EZIG_BUILD_DEMO "Build ezImGui as shared library" ON)
option(EZIG_SHARED_LIB "Build ezImGui as shared library" OFF)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "~CMakeTargets")

# Only generate Debug and Release configuration types.
set(CMAKE_CONFIGURATION_TYPES Debug Release)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug")
endif()

# Use folders in the resulting project files.
set_property(GLOBAL PROPERTY OS_FOLDERS ON)

# C standard
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)

# C++ standard
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/output/$<CONFIG>/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/output/$<CONFIG>/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/output/$<CONFIG>/lib)

if(${CMAKE_SYSTEM_NAME} MATCHES "Android")
  set(EZIG_OS_ANDROID TRUE)
  add_definitions(-DEZIG_OS_ANDROID)
  add_compile_options("-g" "$<$<CONFIG:DEBUG>:-O0>" "$<$<CONFIG:RELEASE>:-O3>")
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  set(EZIG_OS_MACOS TRUE)
  set(EZIG_OS_APPLE TRUE)
  add_definitions(-DEZIG_OS_MACOS)
  add_definitions(-DEZIG_OS_APPLE)
  add_compile_options("-g" "$<$<CONFIG:DEBUG>:-O0>" "$<$<CONFIG:RELEASE>:-O3>")

elseif(${CMAKE_SYSTEM_NAME} MATCHES "iOS")
  set(EZIG_OS_IOS TRUE)
  set(EZIG_OS_APPLE TRUE)
  add_definitions(-DEZIG_OS_IOS)
  add_definitions(-DEZIG_OS_APPLE)
  add_compile_options("-g" "$<$<CONFIG:DEBUG>:-O0>" "$<$<CONFIG:RELEASE>:-O3>")

elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set(EZIG_OS_LINUX 1)
  set(EZIG_OS_POSIX 1)
  add_definitions(-DEZIG_OS_LINUX=1 -DEZIG_OS_POSIX=1)
  add_compile_options("-g" "$<$<CONFIG:DEBUG>:-O0>" "$<$<CONFIG:RELEASE>:-O3>")

elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
  set(EZIG_OS_WINDOWS TRUE)
  add_definitions(-DEZIG_OS_WINDOWS)
  add_link_options(/DEBUG)
  add_compile_options(/Zi /utf-8)
endif()

# ###################################################
# ezimgui lib target
if(EZIG_SHARED_LIB)
  set(EZIMGUI_LIBRARY_TYPE SHARED)
else()
  set(EZIMGUI_LIBRARY_TYPE STATIC)
endif()

# collect common header files
file(GLOB _common_HEADER_FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/imconfig.h
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/imgui.h
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/imgui_internal.h
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/imstb_rectpack.h
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/imstb_textedit.h
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/imstb_truetype.h
)

# collect common source files
file(GLOB _common_SOURCE_FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/imgui_demo.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/imgui_draw.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/imgui_tables.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/imgui_widgets.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/imgui.cpp
)

# collect backend source files for target platform
if(EZIG_OS_WINDOWS)
  include(EzImGui.Windows.cmake)
elseif(EZIG_OS_MACOS)
  include(EzImGui.macOS.cmake)
elseif(EZIG_OS_LINUX)
  include(EzImGui.Linux.cmake)
else()
  message(FATAL "Platform not supported yet")
endif()

source_group(
  TREE ${CMAKE_CURRENT_SOURCE_DIR}/imgui
  PREFIX "include"
  FILES ${_common_HEADER_FILES}
)
source_group(
  TREE ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends
  PREFIX "include"
  FILES ${_backend_HEADER_FILES}
)

source_group(
  TREE ${CMAKE_CURRENT_SOURCE_DIR}/imgui
  PREFIX "source"
  FILES ${_common_SOURCE_FILES}
)
source_group(
  TREE ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends
  PREFIX "source"
  FILES ${_backend_SOURCE_FILES}
)

if(EZIG_COPY_HEADERS)
  foreach(_header_file_path ${_common_HEADER_FILES} ${_backend_HEADER_FILES})
    cmake_path(GET _header_file_path FILENAME _header_file_name)
    message(STATUS "Copy public header: ${_header_file_name}")
    configure_file(
      ${_header_file_path}
      ${CMAKE_CURRENT_SOURCE_DIR}/include/imgui/${_header_file_name}
      COPYONLY
    )
  endforeach()
endif()

add_ezimgui_target(${PROJECT_NAME})
target_include_directories(${PROJECT_NAME}
  PUBLIC
  ${CMAKE_CURRENT_LIST_DIR}/include

  PRIVATE
  ${CMAKE_CURRENT_LIST_DIR}/imgui
  ${CMAKE_CURRENT_LIST_DIR}/imgui/backends
)

if(EZIG_BUILD_DEMO)
  add_exmaple_targets()
endif()