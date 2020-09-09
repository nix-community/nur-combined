{ stdenv
, fetchFromGitHub
, sources
, pkgs
}:

stdenv.mkDerivation {
  pname = "matrix-client";
  version = sources.matrix-client.rev;

  src = fetchFromGitHub {
    owner = "alphapapa";
    repo = "matrix-client.el";
    rev = sources.matrix-client.rev;
    sha256 = sources.matrix-client.sha256;
  };

  buildInputs = with pkgs; [
    emacs
    emacsPackages.ov
    emacsPackages.tracking
    emacsPackages.dash
    emacsPackages.anaphora
    emacsPackages.f
    emacsPackages.a
    emacsPackages.request
    emacsPackages.esxml
    emacsPackages.ht
    emacsPackages.rainbow-identifiers
    emacsPackages.frame-purpose
  ];

  buildPhase = ''
    emacs -L $src --batch -f batch-byte-compile *.el
  '';

  installPhase = ''
    install -d $out/share/emacs/site-lisp
    install *.el *.elc $out/share/emacs/site-lisp
    install -d $out/bin/matrix-client-standalone.el.sh
    install *.sh $out/bin/matrix-client-standalone.el.sh
  '';

  meta = with stdenv.lib; {
    inherit (sources.matrix-client) description homepage;
    license = licenses.gpl3Plus;
    # maintainers = with maintainers; [ yoctocell ];
    platforms = platforms.all;
  };
}
