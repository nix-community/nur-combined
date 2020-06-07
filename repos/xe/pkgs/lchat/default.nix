{ stdenv, fetchgit, libutf, ncurses }:

stdenv.mkDerivation rec {
  pname = "lchat";
  version = "git";
  buildInputs = [ libutf ncurses ];
  src = fetchgit (builtins.fromJSON (builtins.readFile ./source.json));
  prePatch = ''sed -i "s@/usr/local@$out@" config.mk'';

  installPhase = ''
    mkdir -p $out/bin
    make install ||:
  '';
}
