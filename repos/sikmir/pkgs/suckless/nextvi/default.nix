{ lib, stdenv, fetchFromGitHub, memstreamHook }:

stdenv.mkDerivation rec {
  pname = "nextvi";
  version = "2022-03-12";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = pname;
    rev = "883e975c0ac3df739b6e80703a7ab310da792131";
    hash = "sha256-ryhjvGR1kDygcfWEYvwVMn3IrCUKi67XUPj/3I04OW4=";
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
