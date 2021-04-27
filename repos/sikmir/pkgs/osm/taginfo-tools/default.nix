{ lib, stdenv, fetchFromGitHub, cmake, bzip2, expat, gd, icu, libosmium, protozero, sqlite, zlib, sources }:

stdenv.mkDerivation rec {
  pname = "taginfo-tools";
  version = "2020-11-26";

  src = fetchFromGitHub {
    owner = "taginfo";
    repo = pname;
    rev = "52888a81d56e090f7e3b89c99342989ae476bb31";
    sha256 = "sha256-VSO9J0ZAgp7FBJFaD1sm/z1NrehEcnwypBifsMwC3vc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ bzip2 expat gd icu libosmium protozero sqlite zlib ];

  postInstall = ''
    install -Dm755 src/{osmstats,taginfo-sizes} -t $out/bin
  '';

  meta = with lib; {
    description = "C++ tools used in taginfo processing";
    homepage = "https://wiki.openstreetmap.org/wiki/Taginfo";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
