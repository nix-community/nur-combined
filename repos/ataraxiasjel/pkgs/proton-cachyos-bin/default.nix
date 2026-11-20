{
  lib,
  stdenvNoCC,
  fetchzip,
  writeShellApplication,
  curl,
  jq,
  common-updater-scripts,
  mkProtonBinDerivation ? null,
  # null installs the native build (x86_64 on x86_64, arm64 on aarch64);
  # "x86_64_v3" installs the x86-64-v3 build on x86_64.
  variant ? null,
}:

let
  # nixos-26.05 does not have mkProtonBinDerivation yet.
  mkProtonBin =
    if mkProtonBinDerivation != null then
      mkProtonBinDerivation
    else
      import ../proton-bin/mk-proton-bin-derivation.nix { inherit lib stdenvNoCC; };
in
mkProtonBin (finalAttrs: {
  pname = "proton-cachyos-bin" + lib.optionalString (variant == "x86_64_v3") "-v3";
  version = "11.0-20261015";

  steamDisplayName = if variant == "x86_64_v3" then "Proton-CachyOS-v3" else "Proton-CachyOS";

  variants =
    let
      variantData = {
        x86_64 = {
          system = "x86_64-linux";
          asset = "x86_64";
          hash = "sha256-Vb1AvDQLIpgxr3ABPMstM3DFRN1tfUD+6OnhQirMnAQ=";
        };
        x86_64_v3 = {
          system = "x86_64-linux";
          asset = "x86_64_v3";
          hash = "sha256-USZ7wVV069xmGJdtyg6b/pdv7qqLkUkSZEyHiiVIs1o=";
        };
        arm64 = {
          system = "aarch64-linux";
          asset = "arm64";
          hash = "sha256-xV683d43wjkDyERXknf4yDzQbWVlD3w+Wo4H6AxeIis=";
        };
      };

      selected =
        if variant == null then
          [
            "x86_64"
            "arm64"
          ]
        else if builtins.hasAttr variant variantData then
          [ variant ]
        else
          throw "proton-cachyos-bin: unknown variant '${variant}'";
    in
    builtins.listToAttrs (
      map (
        name:
        let
          v = variantData.${name};
        in
        lib.nameValuePair v.system {
          toolName = "proton-cachyos-${finalAttrs.version}-slr-${v.asset}";
          src = fetchzip {
            url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${finalAttrs.version}-slr/proton-cachyos-${finalAttrs.version}-slr-${v.asset}.tar.xz";
            inherit (v) hash;
          };
        }
      ) selected
    );

  # Upstream tags releases as `cachyos-<version>-slr`.
  passthru = {
    updateScript = writeShellApplication {
      name = "update-proton-cachyos";

      runtimeInputs = [
        curl
        jq
        common-updater-scripts
      ];

      text = builtins.readFile ./update.sh;
    };
    # The default package's update script updates every variant.
    skipBulkUpdate = variant == "x86_64_v3";
  };

  meta = {
    description = ''
      Compatibility tool for Steam Play based on Wine and additional components.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://github.com/CachyOS/proton-cachyos";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ataraxiasjel ];
  };
})
