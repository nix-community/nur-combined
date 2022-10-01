{ lib
, stdenv
, cmake
, zlib
, file
, fetchurl
, makeWrapper
, jdk
, flite
, alsaLib
, xorg
, wayland
, libpulseaudio
, libglvnd
, autoPatchelfHook
, libGL
, glfw
, openal
, libbsd }:

stdenv.mkDerivation rec {
  name = "hmcl-bin";
  version = "3.5.3.223";

  src = fetchurl {
    url = "https://github.com/huanghongxun/HMCL/releases/download/v${version}/HMCL-${version}.jar";
    sha256 = "sha256-8g2FMvAiAKfxJUY0G7wl6d44wOpVsknFHGZ85IkOzFc=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ jdk makeWrapper file cmake ];
  buildInputs = [ jdk zlib ];

  phases = [ "installPhase" ];
  installPhase = let
    libpath = with xorg; lib.makeLibraryPath [
      libX11
      libXext
      libXcursor
      libXrandr
      libXxf86vm
      libpulseaudio
      libGL
      glfw
      openal
    ];  
  in ''
    mkdir -p $out/{bin,lib/hmcl-bin}
    cp $src $out/lib/hmcl-bin/hmcl-bin.jar
    makeWrapper  ${jdk}/bin/java $out/bin/hmcl-bin \
      --add-flags "-jar $out/lib/hmcl-bin/hmcl-bin.jar" \
      --set LD_LIBRARY_PATH ${libpath}
  '';

  meta = with lib; {
    homepage = "https://hmcl.huangyuhui.net/";
    description = "A Minecraft Launcher which is multi-functional, cross-platform and popular";
    longDescription = ''
      HMCL is a cross-platform Minecraft launcher which supports Mod Management, Game Customizing, Auto Installing (Forge, Fabric, Quilt, LiteLoader and OptiFine), Modpack Creating, UI Customization, and more.
    '';
    license = "GPL-3.0-or-later";
    maintainers = with maintainers; [ yisuidenghua ];
  };
}
