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

   # version = "local";
   # src = ~/coding/dmenu;

   version = "afdc9bb044ea6d3c85b65695ec1dbccae7f3f202";
   src = fetchFromGitHub {
      owner = "afreakk";
      repo = "dmenu";
      rev = version;
      sha256 = "0rp3r8qc54fxdf0xcbkkl9254xga1bgb5mj8p3h5fsgvqh8j1xw1";
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
      sed -i 's/hack:pixelsize=18:antialias=true:autohint=true/${font}/' config.def.h
   '';
}
