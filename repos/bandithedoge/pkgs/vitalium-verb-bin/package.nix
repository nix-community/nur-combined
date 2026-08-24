{
  fetchzip,
  lib,
  nix-update-script,
  stdenv,

  alsa-lib,
  autoPatchelfHook,
  libGL,
  libx11,
  libxcb,
  libxcb-wm,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vitalium-verb-bin";
  version = "1.3.0";
  src = fetchzip {
    url = "https://github.com/BillyDM/vitalium-verb/releases/download/v${finalAttrs.version}/vitaliumverb-${finalAttrs.version}-ubuntu-22.04.zip";
    sha256 = "sha256-m01aagwJCFRmQTqaVCfrJwqjUjKV20y9aVRiHN1s10E=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    libGL
    libx11
    libxcb
    libxcb-wm
    stdenv.cc.cc.lib
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/{clap,vst3}
    cp VitaliumVerb.clap $out/lib/clap
    cp -r VitaliumVerb.vst3 $out/lib/vst3

    runHook postBuild
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A Rust port of the reverb module from the Vital/Vitalium synthesizer";
    homepage = "https://github.com/BillyDM/vitalium-verb";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
