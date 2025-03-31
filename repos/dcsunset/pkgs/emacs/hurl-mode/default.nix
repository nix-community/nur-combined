{ lib, stdenv, fetchFromGitHub, emacs }:

stdenv.mkDerivation {
  pname = "hurl-mode";
  version = "0-unstable-2025-02-16";

  src = fetchFromGitHub {
    owner = "JasZhe";
    repo = "hurl-mode";
    rev = "df03471e48fb1ca39050d23d61c79ae901e8d68f";
    hash = "sha256-EauCBuqIFhvY5e0lPn9sFFo4K918Rc6Xx9myZTaAXxc=";
  };
  buildInputs = [
    (emacs.pkgs.withPackages (epkgs: with epkgs; [
      json-mode
    ]))
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
    description = "Emacs major mode for the hurl restclient";
    homepage = "https://github.com/JasZhe/hurl-mode";
    license = licenses.gpl3;
  };
}
