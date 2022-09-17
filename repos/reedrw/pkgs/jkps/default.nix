{ stdenv, lib, fetchFromGitHub, cmake, sfml }:

stdenv.mkDerivation rec {
  pname = "jkps";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "JekiTheMonkey";
    repo = "JKPS";
    rev = "6d144f511ab8124d5947cfdada77e5584e002a9b";
    sha256 = "sha256-NveKqapYq//8COndyUpSP8dHiKfTkiH7Yy6b+zdaxtQ=";
  };

  buildInputs = [ cmake sfml ];

  installPhase = ''
    install -D -m777 ./JKPS "$out/bin/JKPS"
  '';

  meta = {
    description = "A keys-per-second meter for rhythm games, useful for streaming and making videos";
    homepage = "https://github.com/JekiTheMonkey/JKPS";
    license = lib.licenses.mit;
  };

}
