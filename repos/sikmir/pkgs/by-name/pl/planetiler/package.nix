{
  lib,
  stdenv,
  fetchfromgh,
  unzip,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "planetiler";
  version = "0.8.3";

  src = fetchfromgh {
    owner = "onthegomap";
    repo = "planetiler";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eUDwcJE3Lq2KfC8fedXVq8kUW6zQNt6HurycXFeoFmw=";
    name = "planetiler.jar";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ jre ];

  installPhase = ''
    install -dm755 $out/bin
    install -Dm644 $src $out/share/java/planetiler.jar

    makeWrapper ${jre}/bin/java $out/bin/planetiler \
      --add-flags "-jar $out/share/java/planetiler.jar"
  '';

  meta = {
    description = "Flexible tool to build planet-scale vector tilesets from OpenStreetMap data";
    homepage = "https://github.com/onthegomap/planetiler";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = jre.meta.platforms;
    skip.ci = true;
  };
})
