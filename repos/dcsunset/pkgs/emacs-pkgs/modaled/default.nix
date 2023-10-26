{ lib, stdenv, fetchFromGitHub, emacsWithPackages }:

stdenv.mkDerivation rec {
  name = "modaled";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "modaled";
    rev = "v${version}";
    hash = "sha256-w3WbNASAd7lYPuXhA5XjprmNjiSh/U2zjLAYnO3U/Wk=";
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
    description = "Build your own minor modes for modal editing in Emacs";
    homepage = "https://github.com/DCsunset/modaled";
    license = licenses.agpl3;
  };
}
