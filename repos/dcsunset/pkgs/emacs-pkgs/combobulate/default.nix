{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "combobulate";
  version = "e37e24de1afa577a19974b6967a4837a2ae5cb98";

  src = fetchFromGitHub {
    owner = "mickeynp";
    repo = "combobulate";
    rev = "${version}";
    hash = "sha256-CUv78OrkVPBxzJlk/px2yJPuLMv4tyJJGvgabjIWi1I=";
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
