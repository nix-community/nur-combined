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
        ./flake-modules/_internal/modules-test-nixos-config.nix
        ./flake-modules/_internal/nixpkgs-options.nix
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      flake = {
        overlay = self.overlays.default;
        overlays = {
          default =
            final: prev:
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
          setupOverlay =
            { config, ... }:
            {
              nixpkgs.overlays = [ self.overlays.default ];
            };
          kata-containers = import ./modules/kata-containers.nix;
          openssl-oqs-provider = import ./modules/openssl-oqs-provider.nix;
          plasma-desktop-lyrics = import ./modules/plasma-desktop-lyrics.nix;
          qemu-user-static-binfmt = import ./modules/qemu-user-static-binfmt.nix;
          wireguard-remove-lingering-links = import ./modules/wireguard-remove-lingering-links.nix;
        };
      };

      perSystem =
        {
          config,
          system,
          pkgs,
          ...
        }:
        {
          packages = import ./pkgs null { inherit inputs pkgs; };

          formatter = pkgs.nixfmt-rfc-style;
        };
    };
}
