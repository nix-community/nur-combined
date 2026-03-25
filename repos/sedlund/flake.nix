{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        flake-parts.flakeModules.partitions
      ];
      partitionedAttrs = {
        checks = "dev";
        devShells = "dev";
        formatter = "dev";
      };
      partitions.dev = {
        extraInputsFlake = ./dev;
        module = {
          imports = [ ./dev/flake-module.nix ];
        };
      };

      perSystem =
        { pkgs, ... }:
        let
          nurAttrs = import ./default.nix { inherit pkgs; };
        in
        {
          packages = pkgs.lib.filterAttrs (_: v: pkgs.lib.isDerivation v) nurAttrs;
        };

      flake.legacyPackages = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
        system:
        import ./default.nix {
          pkgs = import nixpkgs { inherit system; };
        }
      );
    };
}
