{
  lib,
  nix-update-script,
  stdenv,

  juce,
  juceCmakeHook,
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

      buildInputs = [ juce ];

      passthru.updateScript = nix-update-script { };

      meta = {
        license = lib.licenses.gpl3Only;
        platforms = lib.platforms.linux;
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
}
