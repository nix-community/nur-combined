{
  pkgs,
  sources,
}: let
  source = sources.dmenu-flexipatch;
in
  pkgs.stdenv.mkDerivation rec {
    inherit (source) pname src;
    version = source.date;

    buildInputs = with pkgs; [
      xorg.libX11
      xorg.libXinerama
      xorg.libXft
      zlib
    ];

    preConfigure = ''
      sed -i "s@PREFIX = /usr/local@PREFIX = $out@g" config.mk
    '';

    makeFlags = ["CC:=$(CC)"];

    postPatch = ''
      sed -ri -e 's!\<(dmenu|dmenu_path|stest)\>!'"$out/bin"'/&!g' dmenu_run
      sed -ri -e 's!\<stest\>!'"$out/bin"'/&!g' dmenu_path
    '';

    meta = with pkgs.lib; {
      description = "A dmenu build with preprocessor directives to decide which patches to include during build time";
      homepage = "https://github.com/bakkeby/dmenu-flexipatch";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  }
