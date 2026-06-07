{
  maintainers,
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  ninja,
  qt6,
  nodeeditor,
  ffmpeg,
  fftw,
  spdlog,
  yaml-cpp,
  sqlite,
  libpng,
  curl,
  soxr,
  ezpwd-reed-solomon,
  onnxruntime,
  ...
}:
let
  pname = "decode-orc";
  version = "1.1.14";

  rev = "v${version}";
  hash = "sha256-iZxRMV4IAziyEOXpfYKyCTC9JfnRkxGX3YCzkqwDOKY=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "simoninns";
    repo = "decode-orc";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    ninja
  ];

  buildInputs = [
    qt6.qtbase
    qt6.wrapQtAppsHook
    nodeeditor
    ffmpeg
    fftw
    spdlog
    yaml-cpp
    sqlite
    libpng
    ezpwd-reed-solomon
    onnxruntime
    curl
    soxr
  ];

  cmakeFlags = [
    (lib.cmakeFeature "PROJECT_VERSION_OVERRIDE" "${version}")
    (lib.cmakeFeature "EZPWD_INCLUDE_DIR" "${(lib.getLib ezpwd-reed-solomon)}/include")
    (lib.cmakeFeature "BUILD_GUI" "ON")
    (lib.cmakeFeature "BUILD_UNIT_TESTS" "OFF")
    (lib.cmakeFeature "BUILD_GUI_TESTS" "OFF")
  ];

  meta = {
    inherit maintainers;
    description = "The -decode orchestration and processing engine.";
    homepage = "https://github.com/simoninns/decode-orc";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
