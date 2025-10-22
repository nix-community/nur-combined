{
  SDL2,
  alsa-lib,
  carla,
  cmake,
  fetchFromGitHub,
  fftwFloat,
  fltk,
  fluidsynth,
  glibc_multi,
  lame,
  lib,
  libgig,
  libjack2,
  libogg,
  libpulseaudio,
  libsForQt5,
  libsamplerate,
  libsndfile,
  libsoundio,
  libvorbis,
  lilv,
  lv2,
  perl540,
  perl540Packages,
  pkg-config,
  portaudio,
  qt5,
  sndio,
  stdenv,
  substitute,
  suil,
  wineWowPackages,
  withOptionals ? false,
}:

let
  winePackage = if lib.isDerivation wineWowPackages then wineWowPackages else wineWowPackages.minimal;

  wineSrc = fetchFromGitHub {
    owner = "tresf";
    repo = "wine";
    rev = "1f8bb63e75baa5c9f901c8f50b4ea9dd69e0baa0";
    hash = "sha256-x5+uYG6V0v/zHPO33YvT6Q47JQV7CQdnRbVEOa+tLBA=";
  };
in
stdenv.mkDerivation {
  pname = "lmms";
  version = "1.3.0-alpha.1-unstable-2025-10-12";

  src = fetchFromGitHub {
    owner = "LMMS";
    repo = "lmms";
    rev = "807751dc4dce53583ecf4140b67a5dc343c789a7";
    hash = "sha256-hXkH1e8C85JgZLoxDrHhwPBMzHtQt1IwTmb01S0cCAc=";
    fetchSubmodules = true;
  };

  # see https://github.com/LMMS/lmms/blob/807751dc4dce53583ecf4140b67a5dc343c789a7/plugins/VstBase/CMakeLists.txt#L55
  postUnpack = ''
    mkdir $sourceRoot/plugins/VstBase/wine
    cp -r ${wineSrc}/* $sourceRoot/plugins/VstBase/wine/
    chmod -R a+rw $sourceRoot/plugins/VstBase/wine
  '';

  nativeBuildInputs = [
    cmake
    libsForQt5.qt5.qttools
    pkg-config
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    fftwFloat
    libsForQt5.qt5.qtbase
    libsForQt5.qt5.qtx11extras
    libsamplerate
    libsndfile
  ]
  ++ lib.optionals withOptionals [
    SDL2
    alsa-lib
    carla
    fltk
    fluidsynth
    glibc_multi
    lame
    libgig
    libjack2
    libogg
    libpulseaudio
    libsoundio
    libvorbis
    lilv
    lv2
    perl540
    perl540Packages.ListMoreUtils
    perl540Packages.XMLParser
    portaudio
    sndio
    suil
    winePackage
  ];

  patches = lib.optionals withOptionals [
    ./0001-wine-path-patch.patch
    (substitute {
      src = ./0001-fix-add-unique-string-to-FindWine-for-replacement-in.patch;
      substitutions = [
        "--replace-fail"
        "@WINE_LOCATION@"
        winePackage
      ];
    })
  ];

  cmakeFlags = lib.optionals withOptionals [
    "-DWANT_WEAKJACK=OFF"
  ];

  meta = with lib; {
    description = "DAW similar to FL Studio (music production software)";
    mainProgram = "lmms";
    homepage = "https://lmms.io";
    license = licenses.gpl2Plus;
    platforms = [
      "x86_64-linux"
    ];
    broken = stdenv.hostPlatform.isDarwin || stdenv.targetPlatform.isAarch64;
    maintainers = with maintainers; [ wizardlink ];
  };
}
