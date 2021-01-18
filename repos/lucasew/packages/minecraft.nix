{pkgs, ...}:
let
  launcherZip = pkgs.requireFile {
    name = "ShiginimaSE_v4400.zip";
    sha1 = "61cb768106e6e449158ebb2608ad1327402d9fec";
    url = "https://teamshiginima.com/update/";
  };
  envLibPath = with pkgs; stdenv.lib.makeLibraryPath [
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
  drv = pkgs.stdenv.mkDerivation rec {
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
      makeWrapper ${pkgs.jre8}/bin/java $out/bin/minecraft \
          --add-flags "-jar $out/share/java/minecraft.jar" \
                --prefix LD_LIBRARY_PATH : ${envLibPath}
    '';
    meta = {
      homepage = "https://teamshiginima.com/update/";
      description = "Minecraft";
      # license = stdenv.licences.proprietary;
      platforms = pkgs.stdenv.lib.platforms.unix;
    };
  };
in pkgs.makeDesktopItem {
  name = "minecraft";
  desktopName = "Shiginima Minecraft";
  type = "Application";
  icon = builtins.fetchurl {
    url = "https://icons.iconarchive.com/icons/blackvariant/button-ui-requests-2/1024/Minecraft-2-icon.png";
    sha256 = "3cc5dfd914c2ac41b03f006c7ccbb59d6f9e4c32ecfd1906e718c8e47f130f4a";
  };
  exec = "${drv}/bin/minecraft $*";
}
