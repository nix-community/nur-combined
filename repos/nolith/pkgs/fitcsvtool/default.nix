{
  lib,
  requireFile,
  makeWrapper,
  jre,
  stdenvNoCC,
  unzip,
}: let
in
  stdenvNoCC.mkDerivation rec {
    pname = "fitcsvtool";
    version = "21.171.00";
    src = requireFile {
      name = "FitSDKRelease_${version}.zip";
      url = "https://developer.garmin.com/fit/download/";
      sha256 = "sha256-An1flKocjE1JwTtVpcdbeJEBPoFZkzDhq2CYtiNx9tY=";
    };

    nativeBuildInputs = [
      unzip
      makeWrapper
    ];

    unpackPhase = ''
      runHook preUnpack
      mkdir source
      unzip -qq "$src" "java/*" -d source
      runHook postUnpack
    '';

    sourceRoot = "source/java";

    installPhase = ''
      mkdir -pv $out/share/java $out/bin
      cp  *.jar $out/share/java/

      makeWrapper ${jre}/bin/java $out/bin/FitCSVTool \
        --add-flags "-jar $out/share/java/FitCSVTool.jar"
    '';

    meta = {
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      license = lib.licenses.unfree;

      platforms = jre.meta.platforms;
    };
  }
