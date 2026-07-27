{
  sources,

  lib,
  stdenv,

  libx11,
  libxft,
  libxinerama,
}:
stdenv.mkDerivation {
  inherit (sources.dwm-flexipatch) src pname;
  version = sources.dwm-flexipatch.date;

  buildInputs = [
    libx11
    libxinerama
    libxft
  ];

  prePatch = ''
    sed -i "s@/usr/local@$out@" config.mk
  '';

  enableParallelBuilding = true;

  meta = {
    description = "A dwm build with preprocessor directives to decide which patches to include during build time";
    homepage = "https://github.com/bakkeby/dwm-flexipatch";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "dwm";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
