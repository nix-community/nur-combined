{
  sources,

  lib,
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
  inherit (sources.cardinal) src pname;
  version = sources.cardinal.date;

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

  passthru._ignoreDupe = true;

  meta = {
    description = "Virtual modular synthesizer plugin";
    homepage = "https://github.com/DISTRHO/Cardinal";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "Cardinal";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
