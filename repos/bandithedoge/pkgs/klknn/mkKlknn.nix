{
  lib,
  stdenv,
  nix-update-script,

  autoPatchelfHook,
  libx11,
}:
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  extendDrvArgs =
    finalAttrs:
    {
      meta ? { },
      ...
    }:
    {
      nativeBuildInputs = [
        autoPatchelfHook
      ];

      buildInputs = [
        libx11
        stdenv.cc.cc.lib
      ];

      buildPhase = ''
        runHook preBuild

        mkdir -p $out/lib
        cp -r Linux-64b-LV2 $out/lib/lv2
        cp -r Linux-64b-VST3 $out/lib/vst3
        cp -r Linux-64b-VST2 $out/lib/vst

        runHook postBuild
      '';

      passthru.updateScript = nix-update-script { };

      meta = {
        homepage = "https://github.com/klknn/kdr";
        license = lib.licenses.boost;
        platforms = [ "x86_64-linux" ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
}
