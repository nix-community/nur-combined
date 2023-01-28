{ stdenv
, libX11
, libXinerama
, zlib
, libXft
, fetchFromGitHub
, bg0 ? "#1d2021"
, bg1 ? "#282828"
, fg0 ? "#ebdbb2"
, fg1 ? "#fbf1c7"
, accent ? "#fabd2f"
, font ? "hack:pixelsize=18:antialias=true:autohint=true"
}:
stdenv.mkDerivation rec {
  buildInputs = [ libX11 libXinerama zlib libXft ];

  # version = "local";
  # src = ~/coding/dmenu;

  version = "9684ae5252a0cb65124ab87b70402d6a9d2917d3";
  src = fetchFromGitHub {
    owner = "afreakk";
    repo = "dmenu";
    rev = version;
    sha256 = "sha256-sTz67kPRRyRmK5DqHZYvFQA7r0gD7KH+Xba+SmWL2h0=";
  };
  name = "dmenu-afreak";
  preConfigure = ''
    sed -i "s@PREFIX = /usr/local@PREFIX = $out@g" config.mk
    sed -i 's/bg0\[]\s*=\s*".*"/bg0[] = "${bg0}"/' config.def.h
    sed -i 's/bg1\[]\s*=\s*".*"/bg1[] = "${bg1}"/' config.def.h
    sed -i 's/fg0\[]\s*=\s*".*"/fg0[] = "${fg0}"/' config.def.h
    sed -i 's/fg1\[]\s*=\s*".*"/fg1[] = "${fg1}"/' config.def.h
    sed -i 's/accent\[]\s*=\s*".*"/accent[] = "${accent}"/' config.def.h
    sed -i 's/hack:pixelsize=18:antialias=true:autohint=true/${font}/' config.def.h
  '';
}
