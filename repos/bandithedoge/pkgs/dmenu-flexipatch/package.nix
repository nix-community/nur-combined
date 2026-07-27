{
  sources,

  lib,
  stdenv,

  libx11,
  libxft,
  libxinerama,
  zlib,
}:
let
  source = sources.dmenu-flexipatch;
in
stdenv.mkDerivation {
  inherit (source) pname src;
  version = source.date;

  buildInputs = [
    libx11
    libxft
    libxinerama
    zlib
  ];

  preConfigure = ''
    sed -i "s@PREFIX = /usr/local@PREFIX = $out@g" config.mk
  '';

  enableParallelBuilding = true;

  makeFlags = [ "CC:=$(CC)" ];

  postPatch = ''
    sed -ri -e 's!\<(dmenu|dmenu_path|stest)\>!'"$out/bin"'/&!g' dmenu_run
    sed -ri -e 's!\<stest\>!'"$out/bin"'/&!g' dmenu_path
  '';

  meta = {
    description = "A dmenu build with preprocessor directives to decide which patches to include during build time";
    homepage = "https://github.com/bakkeby/dmenu-flexipatch";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "dmenu";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
