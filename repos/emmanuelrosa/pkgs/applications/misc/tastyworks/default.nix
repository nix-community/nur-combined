{ stdenv
, lib
, makeWrapper
, fetchurl
, makeDesktopItem
, copyDesktopItems
, autoPatchelfHook
, openjdk17
, gtk3
, gsettings-desktop-schemas
, writeScript
, bash
, imagemagick
, gnugrep
, gmp
, xorg
, gtk2
, cairo
, glib
, freetype
, dpkg
}:

let 
  pname = "tastyworks";
  version = "1.19.3";

  src = fetchurl rec {
    url = "https://download.${pname}.com/desktop-1.x.x/${version}/${pname}-${version}-1_amd64.deb";
    sha256 = "sha256-XHHQWIhL7IiPwBdKIJl8eJoRabiO+SVewjZuSI4weGM=";
    recursiveHash = true;
    downloadToTemp = true;
    postFetch = ''
      unpackDir="$TMPDIR/unpack"
      mkdir "$unpackDir"
      pushd "$unpackDir"

      ${dpkg}/bin/dpkg -x $downloadedFile .
      popd
      chmod -R +w "$unpackDir"
      mkdir $out
      pushd "$unpackDir"
      mv opt "$out"
      popd
      chmod 755 "$out"
    '';
  };

  launcher = writeScript "tastyworks" ''
    #! ${bash}/bin/bash

    params=(
      -Xms320M 
      -Xmx1200M 
      -XX:+UseG1GC 
      -XX:+UseStringDeduplication 
      -XX:-OmitStackTraceInFastThrow 
      -Drx.scheduler.max-computation-threads=2 
      -Ddxscheme.wide=true 
      -Ddxscheme.price=wide 
      -Ddxscheme.size=wide-cp  
      --add-opens javafx.graphics/com.sun.glass.ui=ALL-UNNAMED
      --add-opens javafx.graphics/com.sun.javafx.application=ALL-UNNAMED
      --add-opens javafx.controls/com.sun.javafx.scene.control=ALL-UNNAMED
      -cp ${tastyworks-libs}/app/*:${tastyworks-libs}/app/lib/*
    )

    XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS ${openjdk17}/bin/java ''${params[@]} com.dough.desktop.launcher.DesktopLauncher $@
'';

  icons = stdenv.mkDerivation {
    pname = "tastyworks-icons";
    inherit version src;
    nativeBuildInputs = [ imagemagick ];

    installPhase = ''
      for n in 16 24 32 48 64 96 128 256; do
        size=$n"x"$n
        mkdir -p $out/hicolor/$size/apps
        convert opt/tastyworks/lib/tastyworks.png -resize $size $out/hicolor/$size/apps/tastyworks.png
      done;
    '';
  };

  tastyworks-libs = stdenv.mkDerivation {
    pname = "tastyworks-libs";
    inherit version src;

    installPhase = ''
      mkdir -p $out
      cp -r opt/tastyworks/lib/app $out
      cp -r opt/tastyworks/share $out
    '';
  };
in stdenv.mkDerivation rec {
  inherit pname version src;
  nativeBuildInputs = [ makeWrapper copyDesktopItems ];

  desktopItems = [
    (makeDesktopItem {
      name = "tastyworks";
      exec = pname;
      icon = pname;
      desktopName = "TastyWorks";
      genericName = "Trading Terminal;";
      categories = "Finance;";
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    ln -s ${tastyworks-libs} $out/lib
    install -D -m 777 ${launcher} $out/bin/tastyworks
    substituteAllInPlace $out/bin/tastyworks

    mkdir -p $out/share/icons
    ln -s ${icons}/hicolor $out/share/icons
    runHook postInstall
  '';

  meta = with lib; {
    description = "We built tastyworks to be one of the fastest, most reliable, and most secure trading platforms in the world. At tastyworks, you can invest your time as wisely as you do your money. With our See It, Click It, Trade It design, your trading becomes efficient, confident, and current.";
    homepage = "https://tastyworks.com/";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
