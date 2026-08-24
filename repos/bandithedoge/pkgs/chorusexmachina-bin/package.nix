{
  lib,
  stdenv,
  fetchzip,
  nix-update-script,

  autoPatchelfHook,
  libGL,
  libx11,
  libxcb,
  unzip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "chorusexmachina-bin";
  version = "1.3";
  src = fetchzip {
    url = "https://github.com/peastman/ChorusExMachina/releases/download/v${finalAttrs.version}/chorus_ex_machina-linux-x86.zip";
    sha256 = "sha256-8xDfLfCd6o1UBLrxw56ZUPE6Aa7ESCBZLfHoqOza3Ak=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
    libGL
    libx11
    libxcb
    stdenv.cc.cc.lib
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/{clap,vst3}
    cp chorus_ex_machina.clap $out/lib/clap
    cp -r chorus_ex_machina.vst3 $out/lib/vst3

    runHook postBuild
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Chorus synthesizer";
    homepage = "https://github.com/peastman/ChorusExMachina";
    license = lib.licenses.lgpl21;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
