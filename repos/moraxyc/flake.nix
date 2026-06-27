{
  description = "Moraxyc's NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/triplet";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs =
    {
      self,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake-modules/nixpkgs-options.nix
        ./flake-modules/by-name.nix
        ./flake-modules/modules.nix
        ./flake-modules/overlay.nix
        inputs.flake-parts.flakeModules.partitions
      ];
      partitions = {
        dev = {
          module = ./flake-modules/dev/modules.nix;
          extraInputsFlake = ./flake-modules/dev;
        };
      };
      partitionedAttrs = {
        checks = "dev";
        devShells = "dev";
        formatter = "dev";
        nixConfig = "dev";
      };
      systems = import inputs.systems;
      flake = {
        lib = import ./lib;
        hydraJobs = {
          inherit (self) ciPackages nixosTests;
        };
      };
    };
}
