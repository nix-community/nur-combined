{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./flakes/ci-outputs.nix
        ./flakes/commands.nix
        ./flakes/nixpkgs.nix
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      flake = {
        overlay = self.overlays.default;
        overlays = {
          default = final: prev:
            import ./pkgs null {
              pkgs = prev;
              inherit inputs;
            };
        };

        nixosModules = {
          setupOverlay = {config, ...}: {
            nixpkgs.overlays = [self.overlays.default];
          };
          openssl-oqs-provider = import ./modules/openssl-oqs-provider.nix;
          qemu-user-static-binfmt = import ./modules/qemu-user-static-binfmt.nix;
        };
      };

      perSystem = {
        config,
        system,
        pkgs,
        ...
      }: {
        packages = import ./pkgs null {inherit inputs pkgs;};
        formatter = pkgs.nixfmt-rfc-style;
      };
    };
}
