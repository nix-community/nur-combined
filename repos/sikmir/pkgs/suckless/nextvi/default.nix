{ lib, stdenv, fetchFromGitHub, memstreamHook }:

stdenv.mkDerivation rec {
  pname = "nextvi";
  version = "2022-02-07";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = pname;
    rev = "0a4a00654fead592ba4ccccfe7046f2f4546fea1";
    hash = "sha256-3dRBQ+DdGR3iqaVOC0c3fz6+a1fdwrdgbdB1jI35ORE=";
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
