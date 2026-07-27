{
  inputs,
  lib,
  self,
  ...
}:

{
  flake.overlays = lib.my.importOverlays ../overlays;

  perSystem =
    { pkgs, system, ... }:
    let
      sources = pkgs.callPackage ../pkgs/_sources/generated.nix { };
      allPkgs = lib.my.importPackages pkgs sources ../pkgs;
      overlays = builtins.attrValues self.overlays;
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
        config.allowInsecure = true;
      };
      packages = lib.my.flattenPkgs "/" allPkgs // { };
      legacyPackages = allPkgs;
    };
}
