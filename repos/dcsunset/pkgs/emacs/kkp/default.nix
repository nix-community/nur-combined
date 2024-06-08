{ lib, stdenv, fetchFromGitHub, emacsWithPackages }:

stdenv.mkDerivation {
  pname = "kkp";
  version = "unstable-2024-06-08";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "kkp";
    rev = "3e2dded6af47becc7d481a8ea60bb9637d182e25";
    hash = "sha256-1fn46mKct6ETkTm0Gs7RjkZ6eahXBZyXAOMqAQujJE4=";
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
