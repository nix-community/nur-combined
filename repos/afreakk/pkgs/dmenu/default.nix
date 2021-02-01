{ stdenv, libX11, libXinerama, zlib, libXft, fetchFromGitHub }:
stdenv.mkDerivation rec {
   buildInputs = [ libX11 libXinerama zlib libXft ];
   # src = ~/coding/dmenu;
   # version = "local";
   version = "691094ab6dc0c2dbfc3721d3aae8b1fc8a537e3a";
   src = fetchFromGitHub {
      owner = "afreakk";
      repo = "dmenu";
      rev = version;
      sha256 = "1fpv6pgaaa2h8hxgihd0iv8ajpljgqbk01vgr9ylh97nb3yhi1qg";
   };
   name = "dmenu-afreak";
   preConfigure = ''
      sed -i "s@PREFIX = /usr/local@PREFIX = $out@g" config.mk
   '';
}
