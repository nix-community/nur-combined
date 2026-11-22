{
  lib,
  stdenvNoCC,
  fetchzip,
  writeShellApplication,
  curl,
  jq,
  common-updater-scripts,
  mkProtonBinDerivation ? null,
}:

let
  mkProtonBin =
    if mkProtonBinDerivation != null then
      mkProtonBinDerivation
    else
      import ../proton-bin/mk-proton-bin-derivation.nix { inherit lib stdenvNoCC; };
in
mkProtonBin (finalAttrs: {
  steamDisplayName = "dwproton";

  pname = "dwproton-bin";
  version = "dwproton-11.0-17";

  variants = {
    "x86_64-linux" = {
      toolName = "${finalAttrs.version}-x86_64";
      src = fetchzip {
        url = "https://dawn.wine/dawn-winery/dwproton/releases/download/${finalAttrs.version}/${finalAttrs.version}-x86_64.tar.xz";
        hash = "sha256-58pd22pNMz+lyp7xYn/nxE6Kere4gh3OiHUwuGsoXfk=";
      };
    };
  };

  passthru = {
    updateScript = "${
      writeShellApplication {
        name = "update-dwproton";

        runtimeInputs = [
          curl
          jq
          common-updater-scripts
        ];

        text = builtins.readFile ./update.sh;
      }
    }/bin/update-dwproton";
  };

  meta = {
    description = ''
      Dawn Winery's custom Proton fork with fixes for various games.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://dawn.wine/dawn-winery/dwproton";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ataraxiasjel ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
