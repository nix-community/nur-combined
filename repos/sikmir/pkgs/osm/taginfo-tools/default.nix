{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  bzip2,
  expat,
  gd,
  icu,
  libosmium,
  protozero,
  sqlite,
  zlib,
}:

stdenv.mkDerivation {
  pname = "taginfo-tools";
  version = "0-unstable-2022-05-24";

  src = fetchFromGitHub {
    owner = "taginfo";
    repo = "taginfo-tools";
    rev = "28264e63a2b3027cec69ae4906ef689029df627b";
    hash = "sha256-AAfrwH+9ON68V8ey5FZge2NVGanQlcxs6qUDnKgt5WU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    bzip2
    expat
    gd
    icu
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
    broken = stdenv.isLinux;
  };
}
