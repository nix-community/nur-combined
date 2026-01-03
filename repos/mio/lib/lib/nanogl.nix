{
  lib,
  writeShellScript,
  runCommand,
  genericBinWrapper,
  mesa,
  libglvnd,
  libvdpau-va-gl,
}:
pkg: vadrivers:
let
  mesa-drivers = [ mesa.drivers ];
  libvdpau = [ libvdpau-va-gl ];

  glxindirect = runCommand "mesa_glxindirect" { } (''
    mkdir -p $out/lib
    ln -s ${mesa.drivers}/lib/libGLX_mesa.so.0 $out/lib/libGLX_indirect.so.0
  '');

  wrapper = writeShellScript "nanogl-wrapper" ''
    export LIBGL_DRIVERS_PATH=${lib.makeSearchPathOutput "lib" "lib/dri" mesa-drivers}
    export LIBVA_DRIVERS_PATH=${lib.makeSearchPathOutput "out" "lib/dri" (mesa-drivers ++ vadrivers)}
    ${
      ''export __EGL_VENDOR_LIBRARY_FILENAMES=${mesa.drivers}/share/glvnd/egl_vendor.d/50_mesa.json"''${__EGL_VENDOR_LIBRARY_FILENAMES:+:$__EGL_VENDOR_LIBRARY_FILENAMES}"''
    }
    export LD_LIBRARY_PATH=${lib.makeLibraryPath mesa-drivers}:${
      lib.makeSearchPathOutput "lib" "lib/vdpau" libvdpau
    }:${glxindirect}/lib:${lib.makeLibraryPath [ libglvnd ]}"''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    exec "@EXECUTABLE@" "$@"
  '';
in
genericBinWrapper pkg wrapper
