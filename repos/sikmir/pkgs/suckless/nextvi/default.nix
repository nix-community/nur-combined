{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "nextvi";
  version = "2022-06-10";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = pname;
    rev = "ffe30839b4ab24ca17ad762ae1f882447f040882";
    hash = "sha256-voS+v4DFNSN2rU3Njhc3ydo8PwVgcPyH7JQoIzrkow4=";
  };

  buildPhase = ''
    sh ./build.sh
  '';

  installPhase = ''
    PREFIX=$out sh ./build.sh install
  '';

  meta = with lib; {
    description = "Next version of neatvi (a small vi/ex editor)";
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
