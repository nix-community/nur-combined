{ lib, stdenv, fetchgit, emacs }:

stdenv.mkDerivation {
  pname = "typst-ts-mode";
  version = "0-unstable-2025-03-18";

  src = fetchgit {
    url = "https://codeberg.org/meow_king/typst-ts-mode.git";
    rev = "e0542e3e42c55983282115a97c13c023a464ff00";
    hash = "sha256-P/6Z4HYwN6A7bcXEiNruv2/NHaoI7DJwYXdJ2z3VEG0=";
  };

  buildInputs = [
    (emacs.pkgs.withPackages (epkgs: []))
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
    description = "Typst tree sitter major mode for Emacs";
    homepage = "https://codeberg.org/meow_king/typst-ts-mode";
    license = licenses.gpl3Only;
  };
}
