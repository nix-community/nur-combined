{ stdenv
, fetchFromGitHub
, sources
, pkgs
}:

stdenv.mkDerivation {
  pname = "eshell-syntax-highlighting";
  version = sources.eshell-syntax-highlighting.rev;

  src = fetchFromGitHub {
    owner = "akreisher";
    repo = "eshell-syntax-highlighting";
    rev = sources.eshell-syntax-highlighting.rev;
    sha256 = sources.eshell-syntax-highlighting.sha256;
  };

  buildInputs = with pkgs; [ emacs ];

  buildPhase = ''
    emacs -L $src --batch -f batch-byte-compile *.el
  '';

  installPhase = ''
    install -d $out/share/emacs/site-lisp
    install *.el *.elc $out/share/emacs/site-lisp
  '';

  meta = with stdenv.lib; {
    inherit (sources.eshell-syntax-highlighting) description homepage;
    license = licenses.gpl3Plus;
    # maintainers = with maintainers; [ yoctocell ];
    platforms = platforms.all;
  };
}
