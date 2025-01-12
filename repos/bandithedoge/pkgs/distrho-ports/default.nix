{
  pkgs,
  sources,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.distrho-ports) pname src;
  version = sources.distrho-ports.date;

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
  ];

  buildInputs = with pkgs; [
    alsa-lib
    fftwFloat
    freetype
    libGL
    xorg.libX11
    xorg.libXext
    xorg.libXcursor
    xorg.libXrender
    xorg.libXinerama
  ];

  prePatch = ''
    sed -i '1s;^;#include <utility>\n;' libs/juce6.1/source/modules/juce_gui_basics/windows/juce_ComponentPeer.h
    patchShebangs scripts/generate-lv2.sh
  '';

  NIX_CFLAGS_COMPILE = ["-fpermissive"];

  meta = with pkgs.lib; {
    description = "Linux audio plugins and LV2 ports";
    homepage = "https://github.com/DISTRHO/DISTRHO-Ports";
    platforms = platforms.linux;
  };
}
