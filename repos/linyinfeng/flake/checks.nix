{ config, self, inputs, ... }:

{
  perSystem = { system, self', pkgs, lib, ... }:
    let
      pkgsStable = import inputs.nixos-stable {
        inherit system;
        inherit (config.nixpkgs) config;
      };
    in
    {
      checks = inputs.flake-utils.lib.flattenTree {
        packages = lib.recurseIntoAttrs self'.legacyPackages;
        packages-stable = lib.recurseIntoAttrs
          (self.lib.makePackages pkgsStable ../pkgs {
            selfLib = self.lib;
          });
        devShells = lib.recurseIntoAttrs self'.devShells;
      };
    };
}
