{
  system,
  pkgs,
  lib,
  writeShellApplication,
}:
let
  emptyDerivation = pkgs.stdenv.mkDerivation {
    name = "empty";
    dontUnpack = true;
  };

  derivations = import ../../packages {
    inherit system pkgs;
  };

  # Get valid top-level derivations for updating
  topDerivations = lib.filterAttrs (
    _: drv:
    lib.isDerivation drv
    # contains a valid updateScript
    && (
      builtins.hasAttr "updateScript" drv
      && builtins.isString drv.updateScript
      && lib.lists.any (cmd: lib.strings.hasSuffix "nix-update" cmd) (
        lib.strings.splitString " " drv.updateScript
      )
    )
    # for the current system
    && (
      !lib.attrsets.hasAttrByPath [ "meta" "platforms" ] drv || builtins.elem system drv.meta.platforms
    )
  ) derivations;

  # Get valid sub derivations for updating
  subDerivations = lib.attrsets.mapAttrs (
    _: top:
    lib.filterAttrs (
      name: drv:
      lib.isDerivation drv
      # is not created by mkDerivation
      && (builtins.elem name (builtins.attrNames emptyDerivation) == false)
      # contains a valid updateScript
      && (
        builtins.hasAttr "updateScript" drv
        && builtins.isString drv.updateScript
        && lib.lists.any (cmd: lib.strings.hasSuffix "nix-update" cmd) (
          lib.strings.splitString " " drv.updateScript
        )
      )
      # for the current system
      && (
        !lib.attrsets.hasAttrByPath [ "meta" "platforms" ] drv || builtins.elem system drv.meta.platforms
      )
    ) top
  ) derivations;

  total =
    (lib.attrsets.collect lib.isDerivation topDerivations)
    ++ (lib.attrsets.collect lib.isDerivation subDerivations);
  commands = map (d: ''
    echo "::group::updating ${d.pname}..."

    {
    ${d.updateScript}
    } || echo "failed to update ${d.pname}"

    echo "::endgroup::"
  '') total;
in
writeShellApplication {
  name = "update";

  runtimeInputs = with pkgs; [
    git
    nix
  ];

  text = lib.strings.concatLines commands;

  meta = {
    description = "Update packages";
    mainProgram = "update";
    platforms = lib.platforms.all;
  };
}
