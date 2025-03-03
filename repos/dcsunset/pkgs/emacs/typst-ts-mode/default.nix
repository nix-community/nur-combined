{ lib, stdenv, fetchgit, emacs }:

stdenv.mkDerivation {
  pname = "modaled";
  version = "0-unstable-2025-02-21";

  src = fetchgit {
    url = "https://codeberg.org/meow_king/typst-ts-mode.git";
    rev = "34d522c0a0d8eec9a8b3a6855cf394e7d5c8fb84";
    hash = "sha256-hx6soqaqyk678vn3LZgkagMwsYOZaMh9TMV3hsJWukI=";
  };

  buildInputs = [
    (emacs.pkgs.withPackages (epkgs: []))
  ];
  buildPhase = ''
    emacs -L . --batch -f batch-byte-compile *.el 2> stderr.txt
    cat stderr.txt
    # ! grep -q ': Warning:' stderr.txt
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
