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
  version = "0-unstable-2026-03-25";

  rev = "f8182c7d6bcc50c77b1fe512c588b32f03134e6d";
  hash = "sha256-9J2AvXWSnxVDft+pq7F59fhP9Wi12VysRjmBR0PlUT0=";
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
    qt6.qtsvg
    qt6.wrapQtAppsHook
    ezpwd-reed-solomon
  ]
  ++ lib.optionals stdenv.isLinux [
    qt6.qtwayland
  ];

  cmakeFlags = [
    (lib.cmakeFeature "EZPWD_DIR" "${(lib.getLib ezpwd-reed-solomon)}/include")
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
