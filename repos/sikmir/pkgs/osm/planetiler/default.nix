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
  version = "0.7.0";

  src = fetchfromgh {
    owner = "onthegomap";
    repo = "planetiler";
    version = "v${finalAttrs.version}";
    name = "planetiler.jar";
    hash = "sha256-rq5cihkU65xtVkrTvVrT7lPoy+Q92aOawYUWxd5LObI=";
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
