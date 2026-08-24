{
  lib,
  nix-update-script,
  stdenv,

  autoPatchelfHook,
  juceCmakeHook,
}:
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  extendDrvArgs =
    finalAttrs:
    {
      product,
      meta ? { },
      ...
    }:
    {
      sourceRoot = "source/${product} v${finalAttrs.version}";

      nativeBuildInputs = [
        autoPatchelfHook
      ];

      buildInputs = [
        stdenv.cc.cc.lib
      ]
      ++ juceCmakeHook.commonBuildInputs;

      buildPhase = ''
        runHook preBuild

        mkdir -p $out/lib/vst3
        cp -r Linux/${product}.vst3 $out/lib/vst3

        runHook postBuild
      '';

      passthru.updateScript = nix-update-script {
        extraArgs = [
          "--use-github-releases"
          "--version-regex"
          "${finalAttrs.pname}-v(.*)"
        ];
      };

      meta = {
        license = lib.licenses.gpl3Plus;
        platforms = [ "x86_64-linux" ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
}
