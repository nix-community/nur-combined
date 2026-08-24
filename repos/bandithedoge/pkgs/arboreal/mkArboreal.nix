{
  lib,
  nix-update-script,
  stdenv,

  juceCmakeHook,
}:
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  extendDrvArgs =
    finalAttrs:
    {
      noLicenseCheck ? false,
      productionBuild ? true,
      meta ? { },
      ...
    }@args:
    {
      nativeBuildInputs = [ juceCmakeHook ];

      cmakeFlags =
        (args.cmakeFlags or [ ])
        ++ (lib.optional noLicenseCheck "-DNO_LICENSE_CHECK=1")
        ++ lib.optional productionBuild "-DPRODUCTION_BUILD=1";

      passthru.updateScript = nix-update-script { };

      meta = {
        license = lib.licenses.gpl3Plus;
        platforms = lib.platforms.linux;
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
}
