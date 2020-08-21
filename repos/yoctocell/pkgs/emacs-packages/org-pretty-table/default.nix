{ stdenv
, fetchFromGitHub
, sources
, emacs
}:

stdenv.mkDerivation {
  pname = "org-pretty-table";
  version = "git";

  src = fetchFromGitHub {
    owner = "Fuco1";
    repo = "org-pretty-table";
    rev = sources.org-pretty-table.rev;
    sha256 = sources.org-pretty-table.sha256;
  };

  buildInputs = [ emacs ];

  buildPhase = ''
  emacs -L $src --batch -f batch-byte-compile *.el
  '';
  
  installPhase = ''
  install -d $out/share/emacs/site-lisp
  install *.el *.elc $out/share/emacs/site-lisp
  '';

  meta = with stdenv.lib; {
    inherit (sources.org-pretty-table) description homepage;
    license = licenses.free;
    # maintainers = with maintainers; [ yoctocell ];
    platforms = platforms.all;
  };
}
    


