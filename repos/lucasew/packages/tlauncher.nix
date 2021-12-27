{ lib
, stdenvNoCC
, openjdk11
, buildFHSUserEnv
, fetchzip
}:
let
  tlauncher = stdenvNoCC.mkDerivation {
    name = "tlauncher-raw";
    src = fetchzip {
      name = "tlauncher.zip";
      url = "https://dl2.tlauncher.org/f.php?f=files%2FTLauncher-2.839.zip";
      sha256 = "sha256-KphpNuTucpuJhXspKxqDyYQN6vbpY0XCB3GAd5YCGbc=";
      stripRoot = false;
    };
    installPhase = ''
      mkdir $out/opt/tlauncher -p
      cp $src/*.jar $out/opt/tlauncher/tlauncher.jar
    '';
  };
  fhs = buildFHSUserEnv {
    name = "tlauncher";
    runScript = ''
      ${openjdk11}/bin/java -jar "${tlauncher}/opt/tlauncher/tlauncher.jar" "$@"
    '';
    targetPkgs = pkgs: with pkgs; [
      alsa-lib
      cpio
      cups
      file
      fontconfig
      freetype
      giflib
      glib
      gnome2.GConf
      gnome2.gnome_vfs
      gtk2
      libjpeg
      libGL
      openjdk8-bootstrap
      perl
      which
      xorg.libICE
      xorg.libX11
      xorg.libXcursor
      xorg.libXext
      xorg.libXi
      xorg.libXinerama
      xorg.libXrandr
      xorg.xrandr
      xorg.libXrender
      xorg.libXt
      xorg.libXtst
      xorg.libXtst
      xorg.libXxf86vm
      zip
      zlib
    ];
  };
in fhs
