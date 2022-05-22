{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "nextvi";
  version = "2022-04-23";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = pname;
    rev = "6e9433f8837d1fdbf1c33a5462809564a25b7d5f";
    hash = "sha256-6zu6sKLFkfUx+tqR3xtaIRm0H8g5zaH9wVe801zffcw=";
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
    platforms = platforms.linux;
    maintainers = [ maintainers.sikmir ];
    skip.ci = stdenv.isDarwin;
  };
}
