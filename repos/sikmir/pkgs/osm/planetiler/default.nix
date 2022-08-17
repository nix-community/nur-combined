{ lib, stdenv, fetchfromgh, unzip, jre, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "planetiler";
  version = "0.5.0";

  src = fetchfromgh {
    owner = "onthegomap";
    repo = "planetiler";
    version = "v${version}";
    name = "planetiler.jar";
    hash = "sha256-XwjY81F1E3MISxwqvSG7OMv2Y1fdKgLSaS01YfFttws=";
  };

  dontUnpack = true;

  buildInputs = [ jre makeWrapper ];

  installPhase = ''
    install -dm755 $out/bin
    install -Dm644 $src $out/share/java/planetiler.jar

    makeWrapper ${jre}/bin/java $out/bin/planetiler \
      --add-flags "-jar $out/share/java/planetiler.jar"
  '';

  meta = with lib; {
    description = "Flexible tool to build planet-scale vector tilesets from OpenStreetMap data";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = jre.meta.platforms;
    skip.ci = true;
  };
}
