{ stdenv
, libX11
, libXinerama
, zlib
, libXft
, fetchFromGitHub
, bg0 ? "#1d2021"
, bg1 ? "#665c54"
, fg0 ? "#bdae93"
, fg1 ? "#fbf1c7"
, font ? "hack:pixelsize=18:antialias=true:autohint=true"
}:
stdenv.mkDerivation rec {
  buildInputs = [ libX11 libXinerama zlib libXft ];

  # version = "local";
  # src = ../../../dmenu;

  version = "17efe43be673b183adab46127a0ded575707e71e";
  src = fetchFromGitHub {
    owner = "afreakk";
    repo = "dmenu";
    rev = version;
    sha256 = "sha256-XOMAbOG0WXn0Z1xzR2NbwAWHAYWy8hsXjyaih3hGyhk";
  };
  name = "dmenu-afreak";
  preConfigure = ''
    sed -i "s@PREFIX = /usr/local@PREFIX = $out@g" config.mk
    sed -i 's/bg0\[]\s*=\s*".*"/bg0[] = "${bg0}"/' config.def.h
    sed -i 's/bg1\[]\s*=\s*".*"/bg1[] = "${bg1}"/' config.def.h
    sed -i 's/fg0\[]\s*=\s*".*"/fg0[] = "${fg0}"/' config.def.h
    sed -i 's/fg1\[]\s*=\s*".*"/fg1[] = "${fg1}"/' config.def.h
    sed -i 's/hack:pixelsize=18:antialias=true:autohint=true/${font}/' config.def.h
  '';
}
