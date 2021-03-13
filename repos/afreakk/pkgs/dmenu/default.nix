{
   stdenv,
   libX11,
   libXinerama,
   zlib,
   libXft,
   fetchFromGitHub,
   bg0 ? "#1d2021",
   bg1	? "#282828",
   bg2	? "#3c3836",
   fg0	? "#ebdbb2",
   fg1	? "#fbf1c7",
   accent	? "#fabd2f",
   font ? "hack:pixelsize=18:antialias=true:autohint=true"
}:
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
      sed -i 's/bg0\[]\s*=\s*".*"/bg0[] = "${bg0}"/' config.def.h
      sed -i 's/bg1\[]\s*=\s*".*"/bg1[] = "${bg1}"/' config.def.h
      sed -i 's/bg2\[]\s*=\s*".*"/bg2[] = "${bg2}"/' config.def.h
      sed -i 's/fg0\[]\s*=\s*".*"/fg0[] = "${fg0}"/' config.def.h
      sed -i 's/fg1\[]\s*=\s*".*"/fg1[] = "${fg1}"/' config.def.h
      sed -i 's/accent\[]\s*=\s*".*"/accent[] = "${accent}"/' config.def.h
      sed 's/hack:pixelsize=18:antialias=true:autohint=true/${font}/' config.def.h
   '';
}
