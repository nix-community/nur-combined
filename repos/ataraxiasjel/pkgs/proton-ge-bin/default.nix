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
  steamDisplayName = "GE-Proton";

  pname = "proton-ge-bin";
  version = "GE-Proton11-12";

  variants = {
    "x86_64-linux" = {
      toolName = "${finalAttrs.version}-x86_64";
      src = fetchzip {
        url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${finalAttrs.version}/${finalAttrs.version}-x86_64.tar.gz";
        hash = "sha256-i20g9lDz7bR0SXWmvHZHztN4m8AHkcD0/OVGSC4ZzI8=";
      };
    };
    "aarch64-linux" = {
      toolName = "${finalAttrs.version}-aarch64";
      src = fetchzip {
        url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${finalAttrs.version}/${finalAttrs.version}-aarch64.tar.gz";
        hash = "sha256-0+ChUSgJa1IUl4yUIYAxP6hbY1oY48zzJYZkAcQZ/0Q=";
      };
    };
  };

  passthru = {
    updateScript = "${
      writeShellApplication {
        name = "update-proton-ge";

        runtimeInputs = [
          curl
          jq
          common-updater-scripts
        ];

        text = builtins.readFile ./update.sh;
      }
    }/bin/update-proton-ge";
  };

  meta = {
    description = ''
      Compatibility tool for Steam Play based on Wine and additional components.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://github.com/GloriousEggroll/proton-ge-custom";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ataraxiasjel ];
  };
})
