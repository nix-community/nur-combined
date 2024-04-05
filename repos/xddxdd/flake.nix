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
        ./flake-modules/ci-outputs.nix
        ./flake-modules/commands.nix
        ./flake-modules/modules-test-nixos-config.nix
        ./flake-modules/nixpkgs-options.nix
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

        nixosModules = {
          setupOverlay =
            { config, ... }:
            {
              nixpkgs.overlays = [ self.overlays.default ];
            };
          kata-containers = import ./modules/kata-containers.nix;
          openssl-oqs-provider = import ./modules/openssl-oqs-provider.nix;
          qemu-user-static-binfmt = import ./modules/qemu-user-static-binfmt.nix;
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
