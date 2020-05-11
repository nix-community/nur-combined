{ gcc8Stdenv, fetchurl, unzip, fltk, libjpeg, writeShellScript }:


let
  oblige_run = writeShellScript "oblige" ''
    #!/bin/sh
    # Find what path this script runs from
    SCRIPT_PATH=$(dirname "$0")

    exec $SCRIPT_PATH/oblige-unwrapped --install $SCRIPT_PATH/../share/oblige "$@"
  '';
in gcc8Stdenv.mkDerivation rec {
  pname = "oblige";
  version = "7.70";
  obaddon-version = "2020-04-13";

  src = fetchurl {
    url = "mirror://sourceforge/project/oblige/Oblige/${version}/oblige-770-source.zip";
    sha256 = "0wc20s63hnxwavny5qmkn1x2s0bp4z8bkz2cnhrcj41xb850ad8d";
  };

  obaddon = fetchurl {
    url = "https://github.com/caligari87/ObAddon/releases/download/${obaddon-version}/ObAddon.pk3";
    sha256 = "0ns7q5ljbkfni7a0wh2dxa7v7s84x3cxmqdgpgh5vj5cnb1hlcvh";
  };

  patches = [ 
    ./fix.patch
  ];

  enableParallelBuilding = true;
  hardeningDisable = [ "all" ];

  buildInputs = [ unzip fltk libjpeg ];

  installPhase = ''
    # Oblige
    install -dm755 "$out/bin"
    install -m755 ${oblige_run} $out/bin/${pname}
    install -m755 Oblige $out/bin/${pname}-unwrapped

    install -d $out/share/oblige/scripts
    install -d $out/share/oblige/engines
    install -d $out/share/oblige/modules
    install -d $out/share/oblige/addons
    install -d $out/share/oblige/language

    install -m644 scripts/*.lua $out/share/oblige/scripts
    install -m644 engines/*.lua $out/share/oblige/engines
    install -m644 modules/*.lua $out/share/oblige/modules
    install -m644 addons/*.pk3 $out/share/oblige/addons
    install -m644 language/*.*  $out/share/oblige/language

    install -d $out/share/oblige/data
    install -d $out/share/oblige/data/bg
    install -d $out/share/oblige/data/masks
    install -m644 data/*.* $out/share/oblige/data
    install -m644 data/bg/*.* $out/share/oblige/data/bg
    install -m644 data/masks/*.* $out/share/oblige/data/masks

    cp -a games $out/share/oblige/games

    mkdir -p $out/share/applications
    cp misc/oblige.desktop $out/share/applications/oblige.desktop
    mkdir -p $out/share/icons/hicolor/128x128/apps
    cp misc/icon_128x128.png $out/share/icons/hicolor/128x128/apps/oblige.png
    
    # ObAddon
    install -m644 $obaddon $out/share/oblige/addons
  '';

  meta = with gcc8Stdenv.lib; {
    description = "A random level generator for classic FPS games";
    license = licenses.gpl2;
    homepage = "https://sourceforge.net/projects/oblige/";
    platforms = platforms.unix;
  };
}
