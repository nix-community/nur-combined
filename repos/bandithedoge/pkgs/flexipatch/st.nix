{
  pkgs,
  sources,
}:
pkgs.stdenv.mkDerivation rec {
  inherit (sources.st-flexipatch) src pname version;

  nativeBuildInputs = with pkgs; [
    pkg-config
    ncurses
    fontconfig
    freetype
  ];

  buildInputs = with pkgs; [
    xorg.libX11
    xorg.libXft
  ];

  strictDeps = true;

  makeFlags = [
    "PKG_CONFIG=${pkgs.stdenv.cc.targetPrefix}pkg-config"
  ];

  postPatch = pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
    substituteInPlace config.mk --replace "-lrt" ""
  '';

  preInstall = ''
    export TERMINFO=$out/share/terminfo
  '';

  installFlags = ["PREFIX=$(out)"];

  meta = with pkgs.lib; {
    description = "An st build with preprocessor directives to decide which patches to include during build time";
    homepage = "https://github.com/bakkeby/st-flexipatch";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
