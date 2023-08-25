{ stdenv, fetchFromGitHub, emacsWithPackages }:

stdenv.mkDerivation rec {
  name = "org-moderncv";
  version = "67f6c0a08c2987ef8b530797d3e0864ae992a440";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "org-moderncv";
    rev = "${version}";
    hash = "sha256-5Sx8U7f7hYsrrhbqIHmLKfNNDimmz5fCNW65qYmjwxE=";
  };
  buildInputs = [
    (emacsWithPackages (epkgs: []))
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
}
