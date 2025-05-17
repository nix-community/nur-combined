# References:
# https://github.com/microsoft/vcpkg/blob/f26ec398c25c4980f33a50391f00a75f7ad62ef7/ports/directx-dxc/portfile.cmake
# https://github.com/microsoft/vcpkg/blob/f26ec398c25c4980f33a50391f00a75f7ad62ef7/ports/directx-dxc/directx-dxc-config.cmake.in

set(DIRECTX_DXC_TOOL
    "@dxc@"
    CACHE PATH "Location of the dxc tool")
mark_as_advanced(DIRECTX_DXC_TOOL)

add_library(Microsoft::DirectXShaderCompiler SHARED IMPORTED)
set_target_properties(
  Microsoft::DirectXShaderCompiler
  PROPERTIES IMPORTED_LOCATION "@dxscLib@/lib/libdxcompiler.so"
             IMPORTED_IMPLIB "@dxscLib@/lib/libdxcompiler.so"
             IMPORTED_SONAME "libdxcompiler.so"
             INTERFACE_INCLUDE_DIRECTORIES "@dxscDev@/include/dxc"
             INTERFACE_LINK_LIBRARIES "Microsoft::DXIL"
             IMPORTED_LINK_INTERFACE_LANGUAGES "C")

add_library(Microsoft::DXIL SHARED IMPORTED)
set_target_properties(
  Microsoft::DXIL
  PROPERTIES IMPORTED_LOCATION "@dxscLib@/lib/libdxil.so"
             IMPORTED_IMPLIB "@dxscLib@/lib/libdxil.so"
             IMPORTED_NO_SONAME TRUE
             INTERFACE_INCLUDE_DIRECTORIES "@dxscDev@/include/dxc"
             IMPORTED_LINK_INTERFACE_LANGUAGES "C")
