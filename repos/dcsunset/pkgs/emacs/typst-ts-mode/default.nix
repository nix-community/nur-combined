{ lib, stdenv, fetchgit, emacs }:

stdenv.mkDerivation {
  pname = "modaled";
  version = "unstable-2024-09-12";

  src = fetchgit {
    url = "https://codeberg.org/meow_king/typst-ts-mode.git";
    rev = "30f54090584a77057463d4bd7972e4cc3cbba4e7";
    hash = "sha256-8fkyK9KxE90oej2WxxKavFIHwPiL/VyPQ/WZx9B/Hr8=";
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
