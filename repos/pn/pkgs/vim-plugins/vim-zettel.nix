{ stdenv, bash, fetchgit }:

stdenv.mkDerivation {
  name = "vim-zettel";

  src = fetchgit {
    url = "https://github.com/michal-h21/vim-zettel";
    rev = "929d90eec62e6f693c2702d2b6f76a93f2f1689d";
    sha256 = "07ma6ylvvyncr24pinvlybygddjdi2r835x7q8c52mnz96dcmz6m";
  };

  buildPhase = ''
  '';

  installPhase = ''
    DEST=$out/share/vim-plugins/vim-zettel
    mkdir -p $DEST
    cp -r * $DEST
  '';
}
