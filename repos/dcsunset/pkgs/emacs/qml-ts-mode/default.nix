{
  lib,
  stdenv,
  fetchFromGitHub,
  emacs
}:

stdenv.mkDerivation {
  pname = "qml-ts-mode";
  version = "0-unstable-2026-10-05";

  src = fetchFromGitHub {
    owner = "xhcoding";
    repo = "qml-ts-mode";
    rev = "b80c6663521b4d0083e416e6712ebc02d37b7aec";
    hash = "sha256-WXK/CdFF9E2kG+uIios4HtKcEMhILS9MddJfVDeRLh0=";
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
    description = "Emacs major mode for editing Qt Declarative (QML) code.";
    homepage = "https://github.com/xhcoding/qml-ts-mode";
    license = licenses.gpl3Only;
  };
}
