{ lib, stdenv, fetchFromGitHub, cmake, bzip2, expat, gd, icu, libosmium, protozero, sqlite, zlib }:

stdenv.mkDerivation rec {
  pname = "taginfo-tools";
  version = "2022-05-04";

  src = fetchFromGitHub {
    owner = "taginfo";
    repo = pname;
    rev = "3b54480e6f4fcfed7bfc064e074250ca97ec4644";
    hash = "sha256-aJQy8BijmiLEOhEzdpzyCC6nK4b1EafZZ/UoZu18LDU=";
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
