{ apisonic, fetchzip }:
apisonic.mkApisonic (finalAttrs: {
  pname = "speedrum";
  version = "2.4.0";
  src = fetchzip {
    url = "https://github.com/apisonic/SP-two/releases/download/v${finalAttrs.version}/speedrum2-v${finalAttrs.version}.zip";
    hash = "sha256-a62zRMKeWU13/sx40eCeAXatSQLsqWIVmLfq96pn1Jw=";
    stripRoot = false;
  };

  product = "Speedrum2";

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/{bin,lib/vst,lib/vst3}
    cp Standalone/Speedrum2 $out/bin
    chmod +x $out/bin/Speedrum2
    cp -r VST3/Speedrum2.vst3 $out/lib/vst3
    cp VST/libSpeedrum2.so $out/lib/vst

    runHook postBuild
  '';

  meta = {
    homepage = "https://www.apisonic-audio.com/speedrum2.html";
    description = "Drum/percussion sampler and sequencer plugin";
  };
})
