{ lib, fetchurl, ghc, stdenv, which }:
stdenv.mkDerivation rec {
  pname = "havm";
  version = "0.28";

  src = fetchurl {
    url = "https://www.lrde.epita.fr/~tiger/download/${pname}-${version}.tar.gz";
    sha256 = "sha256-FDi4FZ8rjGqRkFlROtcJsv+mks7MmIXQGV4bZrwkQrA=";
  };

  nativeBuildInputs = [
    ghc
  ];

  checkInputs = [
    which
  ];

  doCheck = true;

  meta = with lib; {
    description = "A simple virtual machine to execute Andrew Appel's HIR/LIR";
    longDescription = ''
      HAVM is a virtual machine designed to execute simple register based high
      level intermediate code.  It is based on the intermediate representations
      ("canonicalized" or not) defined by Andrew Appel in his "Modern Compiler
      Implementation".
    '';
    homepage = "https://www.lrde.epita.fr/wiki/Havm";
    license = licenses.gpl2Plus;
    platforms = platforms.all;
    maintainers = with maintainers; [ ambroisie ];
  };
}
