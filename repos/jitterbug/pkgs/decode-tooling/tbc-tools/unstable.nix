{
  maintainers,
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  ninja,
  ffmpeg,
  qt6,
  fftw,
  qwt-qt6,
  ezpwd-reed-solomon,
  ...
}:
let
  pname = "tbc-tools";
  version = "2.0.0-unstable-2026-03-25";

  rev = "b49730556d2a2c798f16ab2e649b523ed13a3805";
  hash = "sha256-Tm7W0VXfVNQCo47S9plogd8mBdXyZWDroLVl87I4sLk=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "harrypm";
    repo = "tbc-tools";
    sparseCheckout = [
      "/*"
      "src"
      "!ci"
    ];
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    ninja
  ];

  buildInputs = [
    ffmpeg
    fftw
    qt6.qtbase
    qt6.qtsvg
    qt6.wrapQtAppsHook
    qwt-qt6
    ezpwd-reed-solomon
  ]
  ++ lib.optional stdenv.isLinux [
    qt6.qtwayland
  ];

  cmakeFlags = [
    (lib.cmakeFeature "USE_QT_VERSION" "6")
    (lib.cmakeFeature "EZPWD_DIR" "${(lib.getLib ezpwd-reed-solomon)}/include")
    (lib.cmakeBool "BUILD_PYTHON" false)
    (lib.cmakeBool "BUILD_TESTING" false)
  ];

  meta = {
    inherit maintainers;
    description = "Software defined decoder tools for the decode projects video format and metadata pipeline.";
    homepage = "https://github.com/harrypm/tbc-tools";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainprogram = "ld-analyse";
  };
}
