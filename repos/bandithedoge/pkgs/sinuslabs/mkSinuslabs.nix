{
  lib,
  stdenv,
  nix-update-script,

  autoPatchelfHook,
  juceCmakeHook,
}:
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  extendDrvArgs =
    finalAttrs:
    {
      passthru ? {
        updateScript = nix-update-script { };
      },
      meta ? { },
      ...
    }:
    {
      nativeBuildInputs = [
        autoPatchelfHook
      ];

      buildInputs = juceCmakeHook.commonBuildInputs;

      buildPhase = ''
        runHook preBuild

        mkdir -p $out/lib/vst3
        cp -r *.vst3 $out/lib/vst3

        runHook postBuild
      '';

      inherit passthru;

      meta = {
        platforms = [ "x86_64-linux" ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
}
