{ stdenv, fetchFromGitHub, emacsWithPackages }:

stdenv.mkDerivation rec {
  name = "modaled";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "modaled";
    rev = "v${version}";
    hash = "sha256-L27awkbfPijpudOwqiuD0iHSdS1szS8YjFQfLlhiP/U=";
  };
  buildInputs = [
    (emacsWithPackages (epkgs: []))
  ];
  buildPhase = ''
    emacs -L . --batch -f batch-byte-compile *.el 2> stderr.txt
    cat stderr.txt
    ! grep -q ': Warning:' stderr.txt
  '';
  installPhase = ''
    LISPDIR=$out/share/emacs/site-lisp
    install -d $LISPDIR
    install *.el *.elc $LISPDIR
  '';
}
