option(EZIG_ENABLE_GLFW "Build ezImGui as shared library" ON)

# backend header files
file(GLOB _backend_HEADER_FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_glfw.h
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_opengl2.h
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_opengl3.h
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_win32.h
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_win32.h
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_dx9.h
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_dx10.h
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_dx11.h
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_dx12.h
)

# backend source file
file(GLOB _backend_SOURCE_FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_glfw.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_opengl2.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_opengl3.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_opengl3_loader.h
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_win32.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_dx9.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_dx10.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_dx11.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends/imgui_impl_dx12.cpp
)

if(EZIG_ENABLE_GLFW)
  add_library(glfw3 STATIC IMPORTED)
  set_target_properties(glfw3
    PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_CURRENT_SOURCE_DIR}/imgui/examples/libs/glfw/include
    IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/imgui/examples/libs/glfw/lib-vc2010-$(PlatformArchitecture)/glfw3.lib
  )

  # target_include_directories(${_name}
  # INTERFACE
  # ${CMAKE_CURRENT_SOURCE_DIR}/imgui/examples/libs/glfw/include
  # )
endif()

macro(add_ezimgui_target _name)
  add_library(${_name} ${EZIMGUI_LIBRARY_TYPE}
    ${_common_HEADER_FILES}
    ${_backend_HEADER_FILES}

    ${_common_SOURCE_FILES}
    ${_backend_SOURCE_FILES}
  )

  if(EZIG_ENABLE_GLFW)
    target_link_libraries(${PROJECT_NAME}
      PUBLIC
      glfw3
      opengl32
    )
  endif()
endmacro(add_ezimgui_target)

macro(add_exmaple_target _target)
  add_executable(${_target}
    ${CMAKE_CURRENT_SOURCE_DIR}/imgui/examples/example_${_target}/main.cpp
  )

  target_link_libraries(${_target}
    PRIVATE
    ${PROJECT_NAME}
    ${ARGN}
  )
  set_target_properties(${_target}
    PROPERTIES
    FOLDER example
  )
endmacro()

macro(add_exmaple_targets)
  if(EZIG_ENABLE_GLFW)
    add_exmaple_target(glfw_opengl2 glfw3)
    add_exmaple_target(glfw_opengl3 glfw3)
  endif()

  add_exmaple_target(win32_directx9 d3d9.lib)
  add_exmaple_target(win32_directx10 d3d10.lib)
  add_exmaple_target(win32_directx11 d3d11.lib)
  add_exmaple_target(win32_directx12 d3d12.lib dxgi.lib)
endmacro(add_exmaple_targets)
