{
  sources,

  lib,
  stdenv,

  fontconfig,
  freetype,
  libx11,
  libxft,
  ncurses,
  pkg-config,
}:
stdenv.mkDerivation {
  inherit (sources.st-flexipatch) src pname;
  version = sources.st-flexipatch.date;

  nativeBuildInputs = [
    pkg-config
    ncurses
    fontconfig
    freetype
  ];

  buildInputs = [
    libx11
    libxft
  ];

  strictDeps = true;

  enableParallelBuilding = true;

  makeFlags = [
    "PKG_CONFIG=${stdenv.cc.targetPrefix}pkg-config"
  ];

  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace config.mk --replace "-lrt" ""
  '';

  preInstall = ''
    export TERMINFO=$out/share/terminfo
  '';

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "An st build with preprocessor directives to decide which patches to include during build time";
    homepage = "https://github.com/bakkeby/st-flexipatch";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "st";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
