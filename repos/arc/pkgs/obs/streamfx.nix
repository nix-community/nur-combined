{ fetchFromGitHub, stdenv, obs-studio, cmake, lib, qtbase ? qt5.qtbase, qt5, ffmpeg_4 }: stdenv.mkDerivation rec {
  pname = "obs-streamfx";
  version = "0.11.0a6";

  src = fetchFromGitHub {
    owner = "Xaymar";
    repo = "obs-StreamFX";
    rev = version;
    sha256 = "07vbjg69q691n39a0cbb5x3c2bsdslsh9d3i0f01z7d081w9346s";
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
  buildInputs = [ obs-studio qtbase ffmpeg_4 ];
  dontWrapQtApps = true;

  meta.broken = lib.versionOlder obs-studio.version "27" || lib.versionAtLeast obs-studio.version "28";
}
