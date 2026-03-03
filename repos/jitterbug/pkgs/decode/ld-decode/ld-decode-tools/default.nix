{
  lib,
  stdenv,
  cmake,
  pkg-config,
  ninja,
  ffmpeg,
  qt6,
  fftw,
  ezpwd-reed-solomon,
  ...
}:
stdenv.mkDerivation {
  pname = "ld-decode-tools";

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
    (lib.cmakeBool "BUILD_TESTING" false)
  ];
}
