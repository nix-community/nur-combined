{
  lib,
  makeSetupHook,

  alsa-lib,
  cmake,
  curl-gnutls3,
  fontconfig,
  freetype,
  libGL,
  libx11,
  libxcursor,
  libxext,
  libxinerama,
  libxrandr,
  mold,
  ninja,
  pkg-config,
  writableTmpDirAsHomeHook,
}:
let
  commonBuildInputs = [
    curl-gnutls3
    alsa-lib
    fontconfig
    freetype
    libGL
    libx11
    libxcursor
    libxext
    libxinerama
    libxrandr
  ];
in
makeSetupHook {
  name = "juce-cmake-hook";

  propagatedBuildInputs = [
    cmake
    mold
    ninja
    pkg-config
    writableTmpDirAsHomeHook
  ];

  depsTargetTargetPropagated = commonBuildInputs;

  substitutions = {
    rpath = lib.makeLibraryPath commonBuildInputs;
  };

  passthru = { inherit commonBuildInputs; };

  meta.platforms = lib.platforms.linux;
} ./hook.sh
