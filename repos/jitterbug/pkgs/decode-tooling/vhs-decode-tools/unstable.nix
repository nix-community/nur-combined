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
  pname = "vhs-decode-tools-unstable";
  version = "0.3.9-unstable-2026-03-25";

  rev = "a6eeafdaedc277f34423b307990e0e59ab1715ef";
  hash = "sha256-nGp4QrS2kL5KNrMDGiQ7mQrYmXjXSSgnC6ydgEltohA=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "oyvindln";
    repo = "vhs-decode";
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
    description = "Software Decoder for raw rf captures of laserdisc, vhs and other analog video formats.";
    homepage = "https://github.com/oyvindln/vhs-decode";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainprogram = "vhs-decode";
  };
}
