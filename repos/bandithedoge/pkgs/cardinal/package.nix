{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  SDL2,
  alsa-lib,
  cmake,
  copyDesktopItems,
  dbus,
  fftw,
  freetype,
  glib,
  jansson,
  libGL,
  libarchive,
  liblo,
  libsamplerate,
  libx11,
  libxcursor,
  libxext,
  libxrandr,
  makeDesktopItem,
  mesa,
  pkg-config,
  python3,
  speexdsp,
}:
stdenv.mkDerivation {
  pname = "cardinal";
  version = "26.02-unstable-2026-07-28";
  src = fetchFromGitHub {
    owner = "DISTRHO";
    repo = "Cardinal";
    rev = "0a530b73273afc914ec71a78e9165cd28c53b599";
    hash = "sha256-XaEIge/p/YP9lUABXb6cBvQlD2Sn21sObmmxjvT6Szw=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    pkg-config
    python3
  ];

  dontUseCmakeConfigure = true;

  buildInputs = [
    SDL2
    alsa-lib
    dbus
    fftw
    freetype
    glib
    jansson
    libGL
    libarchive
    liblo
    libsamplerate
    libx11
    libxcursor
    libxext
    libxrandr
    mesa
    speexdsp
  ];

  prePatch = ''
    patchShebangs ./dpf/utils/generate-ttl.sh
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "cardinal";
      exec = "Cardinal";
      desktopName = "Cardinal";
      categories = [
        "AudioVideo"
        "Audio"
      ];
    })
    (makeDesktopItem {
      name = "cardinal-native";
      exec = "CardinalNative";
      desktopName = "Cardinal (Native)";
      categories = [
        "AudioVideo"
        "Audio"
      ];
    })
  ];

  enableParallelBuilding = true;

  makeFlags = [
    "PREFIX=$(out)"
    "SYSDEPS=true"
  ];

  hardeningDisable = [ "format" ];

  passthru = {
    _ignoreDupe = true;
    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch"
      ];
    };
  };

  meta = {
    description = "Virtual modular synthesizer plugin";
    homepage = "https://github.com/DISTRHO/Cardinal";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "Cardinal";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
