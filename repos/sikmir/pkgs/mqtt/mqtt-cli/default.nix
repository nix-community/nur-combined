{
  lib,
  stdenv,
  fetchfromgh,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mqtt-cli";
  version = "4.31.0";

  src = fetchfromgh {
    owner = "hivemq";
    repo = "mqtt-cli";
    name = "mqtt-cli-${finalAttrs.version}.jar";
    hash = "sha256-CqAcH1DI/7n56DDYKBlg82BkDT2l1UcJSxwJ8sTLDjU=";
    version = "v${finalAttrs.version}";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ jre ];

  dontUnpack = true;

  installPhase = ''
    install -dm755 $out/bin
    install -Dm644 $src $out/share/java/${finalAttrs.src.name}

    makeWrapper ${jre}/bin/java $out/bin/mqtt-cli \
      --add-flags "-jar $out/share/java/mqtt-cli-${finalAttrs.version}.jar"
  '';

  meta = {
    description = "MQTT CLI";
    homepage = "https://hivemq.github.io/mqtt-cli/";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = jre.meta.platforms;
  };
})
