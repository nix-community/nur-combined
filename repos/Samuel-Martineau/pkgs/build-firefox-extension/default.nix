{ stdenvNoCC
, callPackage
}: { webextBuildFlags ? [ ]
   , nativeBuildInputs ? [ ]
   , ...
   } @ args:
let
  firefoxExtensionHooks = callPackage ./hooks { };
  inherit (firefoxExtensionHooks) firefoxExtensionBuildHook firefoxExtensionInstallHook;
in
stdenvNoCC.mkDerivation (args
  // {
  nativeBuildInputs = nativeBuildInputs ++ [ firefoxExtensionBuildHook firefoxExtensionInstallHook ];
})
