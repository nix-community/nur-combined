{ stdenv
, fetchFromGitHub
, sources
, pkgs
}:

stdenv.mkDerivation {
  pname = "dired-hacks";
  version = sources.dired-hacks.rev;

  src = fetchFromGitHub {
    owner = "Fuco1";
    repo = "dired-hacks";
    rev = sources.dired-hacks.rev;
    sha256 = sources.dired-hacks.sha256;
  };

  buildInputs = with pkgs; [
    emacs
    emacsPackages.org
    emacsPackages.dash
    emacsPackages.f
    emacsPackages.s
  ];

  buildPhase = ''
    # emacs -L $src --batch -f batch-byte-compile *.el
  '';

  installPhase = ''
    install -d $out/share/emacs/site-lisp
    install *.el *.elc $out/share/emacs/site-lisp
  '';

  meta = with stdenv.lib; {
    inherit (sources.dired-hacks) description homepage;
    license = licenses.free;
    # maintainers = with maintainers; [ yoctocell ];
    platforms = platforms.all;
    broken = true;
  };
}
