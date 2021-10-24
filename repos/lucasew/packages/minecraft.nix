{ pkgs, lib, ... }:
let
  inherit (builtins) fetchurl;
  inherit (lib) makeLibraryPath;
  inherit (pkgs) stdenv makeDesktopItem;

  # java = pkgs.openjdk8;
  java = pkgs.graalvm8-ce;
  launcherZip = fetchurl {
    sha256 = "08la0fazwl4gn6g06iqjfl300q18dpqa8bzc6v16p4lsl9r54bm6";
    url = "https://github.com/lucasew/nixcfg/releases/download/debureaucracyzzz/ShiginimaSE_v4400.zip";
  };
  envLibPath = with pkgs; makeLibraryPath [
    alsaLib # needed for narrator
    curl
    flite # needed for narrator
    libGL
    libGLU
    libpulseaudio
    systemd
    xorg.libX11
    xorg.libXext
    xorg.libXpm
    xorg.libXxf86vm # needed only for versions <1.13
  ];
  drv = stdenv.mkDerivation rec {
    name = "minecraft";
    src = launcherZip;
    dontUnpack = true;
    nativeBuildInputs = with pkgs; [
      makeWrapper
      unzip
    ];
    buildInputs = with pkgs; [
      unzip
    ];
    installPhase = ''
      unzip ${src}
      ls -lha
      mkdir -p $out/share/java $out/bin
      for file in linux_osx/*.jar;
      do
          cat "$file" > $out/share/java/minecraft.jar
      done
      makeWrapper ${java}/bin/java $out/bin/minecraft \
          --add-flags "-jar $out/share/java/minecraft.jar" \
                --prefix LD_LIBRARY_PATH : ${envLibPath}
    '';
    meta = {
      homepage = "https://teamshiginima.com/update/";
      description = "Minecraft";
      license = lib.licenses.unfree;
      platforms = lib.platforms.unix;
    };
  };
in makeDesktopItem {
  name = "minecraft";
  desktopName = "Shiginima Minecraft";
  type = "Application";
  icon = fetchurl {
    url = "https://github.com/lucasew/nixcfg/releases/download/debureaucracyzzz/minecraft.png";
    sha256 = "1bpky4ycdf6w1d9lrhxprsk04jgp26zp9wcm9gy4691di7v8w3iv";
  };
  exec = "${drv}/bin/minecraft $*";
}
