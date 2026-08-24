{
  juceCmakeHook,
  lib,
  nix-update-script,
  stdenv,
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
      nativeBuildInputs = [ juceCmakeHook ];

      cmakeFlags = [
        "-DZL_JUCE_COPY_PLUGIN=FALSE"
      ];

      passthru.updateScript = nix-update-script { };

      meta = {
        license = lib.licenses.gpl3Plus;
        platforms = lib.platforms.linux;
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
}
