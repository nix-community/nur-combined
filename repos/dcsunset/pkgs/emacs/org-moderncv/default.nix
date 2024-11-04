{ lib, stdenv, fetchFromGitHub, emacs }:

stdenv.mkDerivation rec {
  pname = "org-moderncv";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "org-moderncv";
    rev = "v${version}";
    hash = "sha256-wIeA71YX2fOZh6xErhmor3Rf8WzfXZm5uw8B5m08LOQ=";
  };
  buildInputs = [
    (emacs.pkgs.withPackages (epkgs: []))
  ];
  buildPhase = ''
    emacs -L . --batch -f batch-byte-compile *.el 2> stderr.txt
    cat stderr.txt
    ! grep -q ': Warning:' stderr.txt
  '';
  installPhase = ''
    LISPDIR=$out/share/emacs/site-lisp
    install -d $LISPDIR
    install *.el *.elc $LISPDIR
  '';

  meta = with lib; {
    description = "Org exporter for curriculum vitae or cover letter using moderncv";
    homepage = "https://github.com/DCsunset/org-moderncv";
    license = licenses.gpl3;
  };
}
