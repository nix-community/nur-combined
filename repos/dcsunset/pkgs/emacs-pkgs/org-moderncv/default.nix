{ lib, stdenv, fetchFromGitHub, emacsWithPackages }:

stdenv.mkDerivation rec {
  name = "org-moderncv";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "org-moderncv";
    rev = "v${version}";
    hash = "sha256-ta7cH8LTYwj9S7DWBJ2+YjVNnLdp/xb9C2XYX7pV/tw=";
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

  meta = with lib; {
    description = "Org exporter for curriculum vitae or cover letter using moderncv";
    homepage = "https://github.com/DCsunset/org-moderncv";
    license = licenses.gpl3;
  };
}
