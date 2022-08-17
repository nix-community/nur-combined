# Credit: https://github.com/guibou/nixGL
{ lib
, libglvnd
, mesa
, pcre
, pkgsi686Linux
, runCommand
, runtimeShell
, shellcheck
, writeShellScriptBin
, enable32bits ? false
}:
let
  mesaDrivers = [ mesa.drivers ]
    ++ lib.optional enable32bits pkgsi686Linux.mesa.drivers;
  glxindirect = runCommand "mesa_glxindirect" { } ''
    mkdir -p $out/lib
    ln -s ${mesa.drivers}/lib/libGLX_mesa.so.0 $out/lib/libGLX_indirect.so.0
  '';

  driPath = lib.makeSearchPath "lib/dri" mesaDrivers;
  vdpauPath = lib.makeSearchPath "lib/vdpau" mesaDrivers;
  eglVendorPath = lib.makeSearchPath "share/glvnd/egl_vendor.d/50_mesa.json" mesaDrivers;
  ldPath = lib.makeLibraryPath (mesaDrivers ++ [ glxindirect libglvnd ]);
  # XXX: add vulkan support?
in
writeShellScriptBin "nix-gfx-mesa" ''
  export LIBGL_DRIVERS_PATH="${driPath}"
  export LIBVA_DRIVERS_PATH="${driPath}"
  export VDPAU_DRIVER_PATH="${vdpauPath}"
  export __EGL_VENDOR_LIBRARY_FILENAMES="${eglVendorPath}''${__EGL_VENDOR_LIBRARY_FILENAMES:+:$__EGL_VENDOR_LIBRARY_FILENAMES}"
  export LD_LIBRARY_PATH="${ldPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  exec "$@"
''
