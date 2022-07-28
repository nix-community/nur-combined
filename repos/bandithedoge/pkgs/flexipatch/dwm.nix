{
  pkgs,
  sources,
}:
pkgs.stdenv.mkDerivation rec {
  inherit (sources.dwm-flexipatch) src pname version;

  buildInputs = with pkgs; [xorg.libX11 xorg.libXinerama xorg.libXft];

  prePatch = ''
    sed -i "s@/usr/local@$out@" config.mk
  '';

  meta = with pkgs.lib; {
    description = "A dwm build with preprocessor directives to decide which patches to include during build time";
    homepage = "https://github.com/bakkeby/dwm-flexipatch";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
