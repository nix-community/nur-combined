{
  nixpkgs ? <nixpkgs>,
  lib ? nixpkgs.lib,
}:
let
  helpers = {
    mkChildren = children: { inherit children; };

    mkPackage = isFlakeCheck: what: system: package: {
      forSystems = [ system ];
      shortDescription = package.meta.description or "";
      derivationAttrPath = [ ];
      inherit what isFlakeCheck;
    };

    derivationsInventory =
      what: isFlakeCheck: output:
      helpers.mkChildren (
        builtins.mapAttrs (systemType: packagesForSystem: {
          forSystems = [ systemType ];
          children = builtins.mapAttrs (
            packageName: helpers.mkPackage isFlakeCheck what systemType
          ) packagesForSystem;
        }) output
      );

    try =
      e: default:
      let
        res = builtins.tryEval e;
      in
      if res.success then res.value else default;

    isSingle = set: builtins.length (builtins.attrNames set) <= 1;
  };
in
{
  appimages = import ./appimages.nix { inherit helpers lib; };
  bundlers = import ./bundlers.nix { inherit helpers; };
  checks = import ./checks.nix { inherit helpers; };
  devShells = import ./devShells.nix { inherit helpers; };
  formatter = import ./formatter.nix { inherit helpers; };
  images = import ./images.nix { inherit helpers lib; };
  libs = import ./libs.nix { inherit helpers; };
  packages = import ./packages.nix { inherit helpers lib; };
  schemas = import ./schemas.nix { inherit helpers; };
}
