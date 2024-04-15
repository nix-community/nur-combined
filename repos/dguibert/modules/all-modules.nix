{
  config,
  lib,
  ...
}: let
  modulesDir = ./.;

  moduleKinds = lib.filterAttrs (_: type: type == "directory") (builtins.readDir modulesDir);

  mapModules = kind:
    lib.mapAttrs'
    (fn: _:
      lib.nameValuePair
      (lib.removeSuffix ".nix" fn)
      (modulesDir + "/${kind}/${fn}"))
    (lib.filterAttrs
      (modName: _: modName != "all-modules.nix")
      (builtins.readDir (modulesDir + "/${kind}")));

  flakePartsModules = lib.attrValues (mapModules "flake-parts");
in {
  imports = flakePartsModules;

  options.flake.modules = lib.mkOption {
    type = lib.types.anything;
  };

  # generates future flake outputs: `modules.<kind>.<module-name>`
  config.flake.modules = lib.mapAttrs (kind: _: mapModules kind) moduleKinds;

  config.flake.flakeModules = config.flake.modules.flake-parts or {};
  # comapt to current schema: `nixosModules` / `darwinModules`
  config.flake.nixosModules = config.flake.modules.nixos or {};
  config.flake.darwinModules = config.flake.modules.darwin or {};
}
