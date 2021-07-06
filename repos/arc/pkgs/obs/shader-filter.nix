{ fetchFromGitHub, stdenv, obs-studio, ffmpeg, qtbase ? qt5.qtbase, qt5 ? { }, cmake, pkg-config }: stdenv.mkDerivation rec {
  pname = "obs-shader-filter";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "Andersama";
    repo = "obs-studio";
    rev = "v${version}-shader-plugin";
    sha256 = "1hp52f31mlxkp1zdgzh4b36ywn9di98agrwpi6gfs1n7hvw77hiy";
  };

  sourceRoot = "source/plugins/obs-shader-filter";

  patches = [
    ./shader-filter-build.patch
  ];

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ obs-studio ffmpeg qtbase ];

  dontWrapQtApps = true;
}
