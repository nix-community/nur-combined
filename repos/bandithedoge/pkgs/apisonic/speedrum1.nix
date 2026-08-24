{ apisonic, fetchzip }:
apisonic.mkApisonic (finalAttrs: {
  pname = "speedrum1";
  version = "1.5.3";
  src = fetchzip {
    url = "https://github.com/apisonic/SP-one/releases/download/v${finalAttrs.version}/speedrum-v${finalAttrs.version}.zip";
    hash = "sha256-LNADLYHVwjqZH19RXokIW2TQQjACOwZGRpkTccrvJ9A=";
    stripRoot = false;
  };

  product = "Speedrum";

  meta = {
    homepage = "https://www.apisonic-audio.com/speedrum1.html";
    description = "Drum/percussion sampler and sequencer plugin";
  };
})
