{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake-modules/_internal/ci-outputs.nix
        ./flake-modules/_internal/commands.nix
        ./flake-modules/_internal/meta.nix
        ./flake-modules/_internal/modules-test-nixos-config.nix
        ./flake-modules/_internal/nixpkgs-options.nix
        ./flake-modules/_internal/package-meta.nix
        ./flake-modules/_internal/pre-commit-hooks.nix
        ./flake-modules/_internal/treefmt.nix
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      flake = {
        overlay = self.overlays.default;
        overlays = {
          default =
            _final: prev:
            import ./pkgs null {
              pkgs = prev;
              inherit inputs;
            };
        };

        flakeModules = {
          auto-apps-shell = import ./flake-modules/auto-apps-shell.nix;
          auto-colmena-hive = import ./flake-modules/auto-colmena-hive.nix;
        };

        nixosModules = {
          setupOverlay = _: { nixpkgs.overlays = [ self.overlays.default ]; };
          kata-containers = import ./modules/kata-containers.nix;
          nix-cache-attic = import ./modules/nix-cache-attic.nix;
          nix-cache-cachix = import ./modules/nix-cache-cachix.nix;
          nix-cache-garnix = import ./modules/nix-cache-garnix.nix;
          openssl-oqs-provider = import ./modules/openssl-oqs-provider.nix;
          plasma-desktop-lyrics = import ./modules/plasma-desktop-lyrics.nix;
          qemu-user-static-binfmt = import ./modules/qemu-user-static-binfmt.nix;
          wireguard-remove-lingering-links = import ./modules/wireguard-remove-lingering-links.nix;
        };
      };

      perSystem =
        { pkgs, ... }:
        {
          packages = import ./pkgs null { inherit inputs pkgs; };
          legacyPackages = import ./pkgs "legacy" { inherit inputs pkgs; };
        };
    };
}
