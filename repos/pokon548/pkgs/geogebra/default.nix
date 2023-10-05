{ lib, stdenv, unzip, fetchurl, electron, makeWrapper, geogebra }:
let
  pname = "geogebra";
  version = "6-0-804-0";

  srcIcon = geogebra.srcIcon;
  desktopItem = geogebra.desktopItem;

  meta = with lib; {
    description = "Dynamic mathematics software with graphics, algebra and spreadsheets. Patched to use modern interface";
    longDescription = ''
      Dynamic mathematics software for all levels of education that brings
      together geometry, algebra, spreadsheets, graphing, statistics and
      calculus in one easy-to-use package.
    '';
    homepage = "https://www.geogebra.org/";
    maintainers = with maintainers; [ pokon548 voidless sikmir ];
    license = licenses.geogebra;
    sourceProvenance = with sourceTypes; [
      binaryBytecode
      binaryNativeCode  # some jars include native binaries
    ];
    platforms = with platforms; linux ++ darwin;
    hydraPlatforms = [];
  };

  linuxPkg = stdenv.mkDerivation {
    inherit pname version meta;

    src = fetchurl {
      urls = [
        "https://download.geogebra.org/installers/6.0/GeoGebra-Linux64-Portable-${version}.zip"
        "https://web.archive.org/web/20230824011801/https://download.geogebra.org/installers/6.0/GeoGebra-Linux64-Portable-${version}.zip"
      ];
      hash = "sha256-EU5Tf62TIuGujr34qnNORzs8Zqnx2YxaHsX6Vdbqm9c=";
    };

    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [
      unzip
      makeWrapper
    ];

    unpackPhase = ''
      unzip $src
    '';

    installPhase = ''
      mkdir -p $out/libexec/geogebra/ $out/bin
      cp -r GeoGebra-linux-x64/{resources,locales} "$out/"
      makeWrapper ${lib.getBin electron}/bin/electron $out/bin/geogebra --add-flags "$out/resources/app"
      install -Dm644 "${desktopItem}/share/applications/"* \
        -t $out/share/applications/

      install -Dm644 "${srcIcon}" \
        "$out/share/icons/hicolor/scalable/apps/geogebra.svg"

      substituteInPlace $out/resources/app/main.js \
        --replace 'classic.html' 'suite.html'
    '';
  };

  darwinPkg = stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      urls = [
        "https://download.geogebra.org/installers/6.0/GeoGebra-Classic-6-MacOS-Portable-${version}.zip"
        "https://web.archive.org/web/20230824012900/https://download.geogebra.org/installers/6.0/GeoGebra-Classic-6-MacOS-Portable-${version}.zip"
      ];
      hash = "sha256-X/OdQc2Q4i58+78sHaM2bVpKeN4jODQjwIh6z5GSLiA=";
    };

    dontUnpack = true;

    nativeBuildInputs = [ unzip ];

    installPhase = ''
      install -dm755 $out/Applications
      unzip $src -d $out/Applications
    '';

    meta = meta // {
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  };
in
if stdenv.isDarwin
then darwinPkg
else linuxPkg
