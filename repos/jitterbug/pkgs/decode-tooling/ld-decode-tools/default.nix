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
  ezpwd-reed-solomon,
  ...
}:
let
  pname = "ld-decode-tools";
  version = "0-unstable-2026-03-15";

  rev = "5e0a178d7947bb13382bc69cfe247cd3d1f2e619";
  hash = "sha256-ALbbNTzeJC4XLvU0Cta0W8fXotcpmPkFVXf2IR7PEpI=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "simoninns";
    repo = "ld-decode-tools";
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
    description = "Software defined LaserDisc decoder tools.";
    homepage = "https://github.com/simoninns/ld-decode-tools";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainprogram = "ld-analyse";
  };
}
