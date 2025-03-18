{
  lib,
  stdenv,
  fetchurl,
  runCommand,
  autoPatchelfHook,
  autoAddDriverRunpath,
  callPackage,

  perl,
  libglvnd,
  xorg,
  cudatoolkit,
  libxkbcommon,
  glib,
  dbus,
  libuuid,
  fontconfig,
  xcb-util-cursor,
  kdePackages,
  wayland-scanner,
  libGLU,
  vulkan-loader,
}:
let
  version = "2024.3.0.24333";
  libtiff = callPackage ./libtiff { };
  run-file = fetchurl {
    url = "https://developer.nvidia.com/downloads/assets/tools/secure/nsight-graphics/2024_3_0/linux/NVIDIA_Nsight_Graphics_2024.3.0.24333.run";
    hash = "sha256-1jLKfOvgNW4qLk0fj6tr4nL70HWeW/S3hf4WSMutlmI=";
    executable = true;
  };
  installer =
    runCommand "nsight-graphics-installer"
      {
        buildInputs = [
          perl
        ];
      }
      ''
        mkdir -p $out
        ${run-file} --target $out --noexec
        patchShebangs --host $out
      '';
in
stdenv.mkDerivation {
  name = "nsight-graphics";
  inherit version;
  nativeBuildInputs = [
    autoAddDriverRunpath
    autoPatchelfHook
  ];
  buildInputs = [
    libglvnd
    cudatoolkit
    glib
    dbus.lib
    libuuid.lib
    libxkbcommon
    fontconfig.lib
    xorg.libX11
    xorg.xcbutilwm
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xcb-util-cursor
    kdePackages.full
    wayland-scanner
    libtiff
    libGLU
  ];
  dontUnpack = true;
  autoPatchelfIgnoreMissingDeps = [ "libcuda.so.1" ];
  runtimeDependencies = [
    vulkan-loader
  ];
  dontAutoPatchelf = true;
  installPhase = ''
    env -C ${installer} ./install-linux.pl -noprompt -targetpath=$PWD
    cp -r NVIDIA-Nsight-Graphics-* $out
    ln -sr $out/host/linux-desktop-nomad-x64 $out/bin
  '';
  postFixup = ''
    autoPatchelf $out/bin
  '';
  meta.mainProgram = "ngfx-ui";
  meta.license = lib.licenses.unfree;
}
