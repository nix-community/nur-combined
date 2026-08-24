{
  lib,
  stdenv,
  autoPatchelfHook,
  juceCmakeHook,
  nix-update-script,
}:
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  extendDrvArgs =
    finalAttrs:
    {
      product,
      meta ? { },
      sourceRoot ? "source/linux",
      buildPhase ? ''
        runHook preBuild

        mkdir -p $out/lib/{vst,vst3}
        cp -r .vst3/${product}.vst3 $out/lib/vst3
        cp .vst/${product}.so $out/lib/vst

        runHook postBuild
      '',
      ...
    }:
    {
      inherit sourceRoot;

      nativeBuildInputs = [
        autoPatchelfHook
      ];

      buildInputs = juceCmakeHook.commonBuildInputs;

      inherit buildPhase;

      passthru.updateScript = nix-update-script { };

      meta = {
        license = lib.licenses.unfree;
        platforms = [ "x86_64-linux" ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
}
