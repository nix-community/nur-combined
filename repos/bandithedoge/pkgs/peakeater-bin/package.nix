{
  fetchzip,
  lib,
  nix-update-script,
  stdenv,

  autoPatchelfHook,
  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "peakeater-bin";
  version = "0.8.2";
  src = fetchzip {
    url = "https://github.com/vvvar/PeakEater/releases/download/v${finalAttrs.version}/peakeater-v${finalAttrs.version}-Linux-x86_64.zip";
    sha256 = "sha256-jfs1T8bumU+9XALB+AY8cKHdMP72vQRSS8EapieCkrY=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ]
  ++ juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/{clap,lv2,vst3}
    cp Release/CLAP/peakeater.clap $out/lib/clap
    cp -r Release/LV2/peakeater.lv2 $out/lib/lv2
    cp -r Release/VST3/peakeater.vst3 $out/lib/vst3

    runHook postBuild
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "PeakEater is a free open-source cross-platform VST3/AU/LV2/CLAP wave shaper plugin";
    homepage = "https://github.com/vvvar/PeakEater";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
