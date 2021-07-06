{ fetchFromGitHub, stdenv, obs-studio, cmake, lib, qtbase ? qt5.qtbase, qt5, ffmpeg }: stdenv.mkDerivation rec {
  pname = "obs-streamfx";
  version = "0.11.0a3";

  src = fetchFromGitHub {
    owner = "Xaymar";
    repo = "obs-StreamFX";
    rev = version;
    sha256 = "0fwnbv40rlsfaa5pqim9yrby133b654r3zlag24md90ibjhj67s3";
  };

  patches = [
    ./streamfx-cmake.patch
  ];

  cmakeFlags = [
    "-DSTRUCTURE_PACKAGEMANAGER=ON"
    "-DDOWNLOAD_QT=OFF"
    "-DVERSION=${version}"
    "-DENABLE_UPDATER=OFF"
  ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ obs-studio qtbase ffmpeg ];
  dontWrapQtApps = true;

  meta.broken = lib.versionOlder obs-studio.version "27";
}
