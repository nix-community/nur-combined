{ lib, stdenv, fetchFromGitHub, emacs }:

stdenv.mkDerivation {
  pname = "hurl-mode";
  version = "unstable-2024-11-13";

  src = fetchFromGitHub {
    owner = "JasZhe";
    repo = "hurl-mode";
    rev = "3b00699827140f300a0abbd90a5d88d32076b0a5";
    hash = "sha256-bpUMevKGRVeyJGFQHbz/iuG/ow91Z1uesBk2N27+jtM=";
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
