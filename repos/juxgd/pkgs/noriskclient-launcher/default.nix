{
  addDriverRunpath,
  alsa-lib,
  callPackage,
  glfw3-minecraft,
  lib,
  libGL,
  libX11,
  libXcursor,
  libXext,
  libXrandr,
  libXrender,
  libXxf86vm,
  libjack2,
  libpulseaudio,
  mesa-demos,
  noriskclient-launcher-unwrapped,
  openal,
  pciutils,
  pipewire,
  stdenv,
  symlinkJoin,
  udev,
  vulkan-loader,
  makeWrapper,
  xrandr,

  additionalLibs ? [ ],
  additionalPrograms ? [ ],
}:

let
  noriskclient-launcher' = noriskclient-launcher-unwrapped;
in
symlinkJoin {
  name = "noriskclient-launcher-${noriskclient-launcher'.version}";

  paths = [ noriskclient-launcher' ];

  postPatch =
    let # i did not shamelessly copy this from the prismlauncher package declaration idk what you're talking about
      runtimeLibs = [
        glfw3-minecraft
        openal

        alsa-lib
        libjack2
        libpulseaudio
        pipewire

        libGL
        libX11
        libXcursor
        libXext
        libXrandr
        libXrender
        libXxf86vm

        udev

        vulkan-loader
      ] ++ additionalLibs;

      runtimePrograms = [
        mesa-demos
        pciutils
        xrandr
      ] ++ additionalPrograms;
    in
    (noriskclient-launcher'.postPatch or "") + ''
      wrapProgram $out/bin/noriskclient-launcher-v3 --set PATH ${lib.makeBinPath runtimePrograms} --set LD_LIBRARY_PATH ${lib.makeLibraryPath runtimeLibs}
    '';

  inherit (noriskclient-launcher') meta;
}
