{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "combobulate";
  version = "unstable-2024-03-02";

  src = fetchFromGitHub {
    owner = "mickeynp";
    repo = "combobulate";
    rev = "abc2be2a47edd2d108ce0dbe1d11e0cd2fe6796d";
    hash = "sha256-LDjwiDlEIpWVxLFi8Cay1P3LNh1pl4GC17lNKK7QTyo=";
  };
  # byte compile not working now
  # buildInputs = [
  #   (pkgs.emacsWithPackages (epkgs: []))
  # ];
  buildPhase = ''
    # make byte-compile
  '';
  installPhase = ''
    LISPDIR=$out/share/emacs/site-lisp
    install -d $LISPDIR
    install *.el *.elc $LISPDIR
  '';

  meta = with lib; {
    description = "Structured Editing and Navigation in Emacs";
    homepage = "https://github.com/mickeynp/combobulate";
    license = licenses.gpl3;
  };
}
