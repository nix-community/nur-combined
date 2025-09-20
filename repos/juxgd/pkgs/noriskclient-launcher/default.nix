# i know this is technically not a wrapper but idc
{
  maintainers-list,

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

  rustPlatform,

  additionalLibs ? [ ],
  additionalPrograms ? [ ],
}:

let
  noriskclient-launcher' = noriskclient-launcher-unwrapped;

  # i did not shamelessly copy this from the prismlauncher package declaration idk what you're talking about
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
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "noriskclient-launcher";
  inherit (noriskclient-launcher') version;
  inherit (noriskclient-launcher') src;

  inherit (noriskclient-launcher') cargoHash;

  inherit (noriskclient-launcher') yarnOfflineCache;

  nativeBuildInputs = [] ++ noriskclient-launcher'.nativeBuildInputs;

  buildInputs = [] ++ noriskclient-launcher'.buildInputs ++ runtimeLibs ++ runtimePrograms;

  inherit (noriskclient-launcher') cargoRoot;
  inherit (noriskclient-launcher') buildAndTestSubdir;

  inherit (noriskclient-launcher') postPatch;

  meta = {
    description = "Launcher for the NoRiskClient PvP client for Minecraft";
    branch = "v3";
    homepage = "https://norisk.gg/";
    downloadPage = "https://github.com/";
    maintainers = [
      maintainers-list.JuxGD
    ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "noriskclient-launcher-v3";
    broken = true;
  };
})