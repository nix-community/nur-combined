{
  description = "Moraxyc's NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/triplet";
    flake-parts.url = "github:hercules-ci/flake-parts";

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # extraPackages
    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };
  outputs =
    {
      self,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake-modules/commands.nix
        ./flake-modules/nixpkgs-options.nix
        ./flake-modules/by-name.nix
        ./flake-modules/modules.nix
        ./flake-modules/nix-config.nix
        ./flake-modules/overlay.nix
        ./flake-modules/treefmt.nix
        ./flake-modules/git-hooks.nix
      ];
      systems = import inputs.systems;
      flake = {
        lib = import ./lib;
        hydraJobs = {
          inherit (self) ciPackages nixosTests;
        };
      };
    };
}
