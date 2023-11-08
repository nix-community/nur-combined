{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "combobulate";
  version = "unstable-2023-09-25";

  src = fetchFromGitHub {
    owner = "mickeynp";
    repo = "combobulate";
    rev = "c7e4670a3047c0b58dff3746577a5c8e5832cfba";
    hash = "sha256-oLxJfHN50GWlXZYmZP7ZGqyvwEG3h0HreLAfBqoWfBg=";
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
