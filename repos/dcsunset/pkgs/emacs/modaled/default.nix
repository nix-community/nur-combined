{ lib, stdenv, fetchFromGitHub, emacs }:

stdenv.mkDerivation rec {
  pname = "modaled";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "modaled";
    rev = "v${version}";
    hash = "sha256-ygoo+uJOnAqd1Tzx8cM0gy9HaJGsehAB6XyDzV6147w=";
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
    description = "Build your own minor modes for modal editing in Emacs";
    homepage = "https://github.com/DCsunset/modaled";
    license = licenses.agpl3Only;
  };
}
