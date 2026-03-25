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
  pname = "vhs-decode";
  version = "0.3.9";

  rev = "v${version}";
  hash = "sha256-FehJW/4lkstM0WI9EhEGOTnEls9E5MGHY/QGMGpg+QY=";
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
