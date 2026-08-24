{
  lib,
  nix-update-script,
  stdenv,

  autoPatchelfHook,
  libGL,
  libx11,
  libxcb,
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
        libGL
        libx11
        libxcb
      ];

      buildPhase = ''
        runHook preBuild

        mkdir -p $out/lib/{clap,vst3}
        cp ${finalAttrs.pname}.clap $out/lib/clap/${finalAttrs.pname}.clap
        cp -r ${finalAttrs.pname}.vst3 $out/lib/vst3/${finalAttrs.pname}.vst3

        runHook postBuild
      '';

      passthru.updateScript = nix-update-script {
        extraArgs = [
          "--version-regex"
          "release-(\\d+)"
        ];
      };

      meta = {
        license = lib.licenses.unfree;
        platforms = [ "x86_64-linux" ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
}
