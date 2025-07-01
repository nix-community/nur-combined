{
  lib,
  fetchFromGitHub,
  stdenv,
  unstableGitUpdater,

  # Native Build Inputs
  cmake,
  python3,
  pkg-config,

  # Build Inputs
  xorg,
  wayland,
  libxkbcommon,
  wayland-protocols,
  glew,
  qt6,
  mesa,
  alsa-lib,
  sdl3,
  iniparser,

  # Options
  imguiDebug ? false,
  addrSan ? false,
  emscriptenHost ? "",
}:
stdenv.mkDerivation (finalAttrs: {
  strictDeps = true;
  name = "isle-portable";
  version = "0-unstable-2025-06-23";

  src = fetchFromGitHub {
    owner = "isledecomp";
    repo = "isle-portable";
    rev = "19fee55333ee4a422f95f5279afcae0cef20d961";
    hash = "sha256-DwMrj71CODRbx1QzNj9LuaCmZ+1kllH+0XkVv5jlSaU=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "lib"
  ];

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
    python3
    pkg-config
  ];

  buildInputs =
    [
      qt6.qtbase
      sdl3
      iniparser
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      xorg.libX11
      xorg.libXext
      xorg.libXrandr
      xorg.libXrender
      xorg.libXfixes
      xorg.libXi
      xorg.libXinerama
      xorg.libXcursor
      wayland
      libxkbcommon
      wayland-protocols
      glew
      mesa
      alsa-lib
    ];

  cmakeFlags = [
    (lib.strings.cmakeBool "DOWNLOAD_DEPENDENCIES" false)
    (lib.strings.cmakeBool "ISLE_DEBUG" imguiDebug)
    (lib.strings.cmakeFeature "ISLE_EMSCRIPTEN_HOST" emscriptenHost)
  ];

  passthru.updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };

  meta = {
    description = "A portable version of LEGO Island (Version 1.1, English) based on the isle decompilation project.";
    homepage = "https://github.com/isledecomp/isle-portable";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
    mainProgram = "isle";
    maintainers = with lib.maintainers; [
      RossSmyth
    ];
  };
})
