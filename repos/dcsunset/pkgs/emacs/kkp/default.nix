{ lib, stdenv, fetchFromGitHub, emacs }:

stdenv.mkDerivation {
  pname = "kkp";
  version = "0-unstable-2025-06-04";

  src = fetchFromGitHub {
    owner = "benotn";
    repo = "kkp";
    rev = "fix-issue-17-daemon-mode";
    hash = "sha256-2qG3sLwpEfDZSHJb8DGY/81jAwjW57gFKvzAX0+BtWI=";
  };
  buildInputs = [
    (emacs.pkgs.withPackages (epkgs: with epkgs; [ compat ]))
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
    homepage = "https://github.com/benotn/kkp";
    license = licenses.gpl3Only;
  };
}
