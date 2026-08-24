{
  lib,
  stdenvNoCC,
}:

lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;
  extendDrvArgs =
    finalAttrs:
    {
      steamDisplayName ? finalAttrs.pname,
      meta ? { },
      ...
    }:
    {
      outputs = [
        "out"
        "steamcompattool"
      ];

      buildPhase = ''
        runHook preBuild

        mkdir -p $out/share/steam/compatibilitytools.d/$pname
        cp -r * $out/share/steam/compatibilitytools.d/$pname
        ln -s $out/share/steam/compatibilitytools.d/$pname $steamcompattool
        substituteInPlace $steamcompattool/compatibilitytool.vdf \
          --replace-fail "${finalAttrs.version}" "${steamDisplayName}"

        runHook postBuild
      '';

      meta = {
        license = lib.licenses.bsd3;
        platforms = [ "x86_64-linux" ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
}
