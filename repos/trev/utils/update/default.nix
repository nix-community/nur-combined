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

  attrs = import ../../packages {
    inherit system pkgs;
  };

  # Get valid top-level derivations for updating
  topDerivations = lib.filterAttrs (
    _: top:
    lib.isDerivation top
    && top ? "updateScript"
    && builtins.isString top.updateScript
    && lib.lists.any (cmd: lib.strings.hasSuffix "nix-update" cmd) (
      lib.strings.splitString " " top.updateScript
    )
  ) attrs;

  # Get valid sub derivations for updating
  subDerivations = lib.attrsets.mapAttrs (
    _: top:
    lib.filterAttrs (
      name: subdrv:
      lib.isDerivation subdrv
      # is not created by mkDerivation
      && (builtins.elem name (builtins.attrNames emptyDerivation) == false)
      # contains a valid updateScript
      && (
        subdrv ? "updateScript"
        && builtins.isString subdrv.updateScript
        && lib.lists.any (cmd: lib.strings.hasSuffix "nix-update" cmd) (
          lib.strings.splitString " " subdrv.updateScript
        )
      )
    ) top
  ) attrs;

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
