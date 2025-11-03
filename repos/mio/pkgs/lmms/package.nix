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
in
stdenv.mkDerivation {
  pname = "lmms";
  version = "1.2.2-unstable-2025-10-31";

  src = fetchFromGitHub {
    owner = "LMMS";
    repo = "lmms";
    rev = "fcb356df3d390799dc97c2089ec1eb4198efe3b9";
    hash = "sha256-mmtQS/o3MR56rA+7wgewxezm7fz2H5zn9b1Wcsnwvuw=";
    fetchSubmodules = true;
  };

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
