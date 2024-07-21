{ lib, stdenv, fetchFromGitHub, emacsWithPackages }:

stdenv.mkDerivation {
  pname = "kkp";
  version = "0-unstable-2024-07-21";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "kkp";
    rev = "d6796cd0283e5b6301cf9fd22600049a04e45e65";
    hash = "sha256-+r21xJuQD9ExzN5XFQ+DUMOJ2qxnLQa+8lSrSUJduN4=";
  };
  buildInputs = [
    (emacsWithPackages (epkgs: with epkgs; [ compat ]))
  ];
  buildPhase = ''
    emacs -L . --batch -f batch-byte-compile *.el
  '';
  installPhase = ''
    LISPDIR=$out/share/emacs/site-lisp
    install -d $LISPDIR
    install *.el *.elc $LISPDIR
  '';

  meta = with lib; {
    description = "Emacs support for the Kitty Keyboard Protocol";
    homepage = "https://github.com/DCsunset/kkp";
    license = licenses.agpl3Only;
  };
}
