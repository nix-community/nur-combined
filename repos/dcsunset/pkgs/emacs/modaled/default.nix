{ lib, stdenv, fetchFromGitHub, emacsWithPackages }:

stdenv.mkDerivation rec {
  pname = "modaled";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "modaled";
    rev = "v${version}";
    hash = "sha256-H31yp7ZGUYrLkmZj/0Ft854Tz4wy8Zz3TRwcoT5M36A=";
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

  meta = with lib; {
    description = "Build your own minor modes for modal editing in Emacs";
    homepage = "https://github.com/DCsunset/modaled";
    license = licenses.agpl3Only;
  };
}
