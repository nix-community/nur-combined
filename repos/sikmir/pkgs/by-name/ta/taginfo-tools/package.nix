{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  bzip2,
  expat,
  gd,
  icu74,
  libosmium,
  protozero,
  sqlite,
  zlib,
}:

stdenv.mkDerivation {
  pname = "taginfo-tools";
  version = "0-unstable-2024-11-24";

  src = fetchFromGitHub {
    owner = "taginfo";
    repo = "taginfo-tools";
    rev = "a92fa2e9cdbc60c1edda57e652b1b9faad44faa5";
    hash = "sha256-uYUYF5FGsxqReJdFBGStvJnx/uaQG8k2pgr5Gjh2IH0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    bzip2
    expat
    gd
    icu74
    libosmium
    protozero
    sqlite
    zlib
  ];

  postInstall = ''
    install -Dm755 src/{osmstats,taginfo-sizes} -t $out/bin
  '';

  meta = {
    description = "C++ tools used in taginfo processing";
    homepage = "https://wiki.openstreetmap.org/wiki/Taginfo";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
