{
    description = "My personal NUR repository";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
        systems.url = "github:nix-systems/x86_64-linux";
        flake-parts.url = "github:hercules-ci/flake-parts";
        devshell = {
            url = "github:numtide/devshell";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        treefmt-nix = {
            url = "github:numtide/treefmt-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nima = {
            url = "github:Vortriz/nix-manipulator";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.systems.follows = "systems";
        };
    };

    outputs =
        { nixpkgs, flake-parts, ... }@inputs:
        flake-parts.lib.mkFlake { inherit inputs; } {
            systems = import inputs.systems;

            imports = [
                ./devshell.nix
                ./treefmt.nix
            ];

            perSystem =
                {
                    pkgs,
                    system,
                    ...
                }:
                {
                    _module.args.pkgs = import nixpkgs {
                        inherit system;
                        config.allowUnfree = true;
                    };

                    legacyPackages = import ./default.nix { inherit pkgs; };
                };

            flake = {
                overlays = import ./overlay.nix;
                homeModules = import ./modules/home-manager;
            };
        };
}
