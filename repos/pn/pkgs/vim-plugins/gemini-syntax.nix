{ stdenv, bash, fetchgit }:

stdenv.mkDerivation {
  name = "gemini-vim-syntax";

  src = fetchgit {
    url = "https://tildegit.org/sloum/gemini-vim-syntax";
    rev = "5c206be6d5635500dd2276681050a40ddb0ba5e3";
    sha256 = "0s0yqj85vadlyny0cw0n5gvhdiy537b0fnycpnahwmbwha2p3mc1";
  };

  buildPhase = ''
    rm Makefile
  '';

  installPhase = ''
    DEST=$out/share/vim-plugins/gemini-vim-syntax
    mkdir -p $DEST
    cp -r ftdetect $DEST
    cp -r syntax $DEST
  '';
}
