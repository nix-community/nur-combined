{ stdenv, pkgs, fetchgit, pkgconfig, libX11, ncurses, libXft }:

let
  pname = "st";
  version = "0.8.4-uleenucks";
in stdenv.mkDerivation {
  inherit pname version;

  src = fetchgit (builtins.fromJSON (builtins.readFile ./source.json));

  nativeBuildInputs = [ pkgconfig ncurses ];
  buildInputs = [ libX11 libXft ];

  prePatch = ''sed -i "s@/usr/local@$out@" config.mk'';

  buildPhase = " make ";

  installPhase = ''
    TERMINFO=$out/share/terminfo make install PREFIX=$out
  '';

  meta = {
    homepage = "https://st.suckless.org/";
    description = "Simple Terminal for X from Suckless.org Community";
    license = pkgs.lib.licenses.mit;
    platforms = with pkgs.lib.platforms; all;
  };
}
