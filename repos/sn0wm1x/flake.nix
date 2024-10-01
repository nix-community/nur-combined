{
  description = "github:sn0wm1x/ur";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      homeManagerModules = import ./modules/home-manager;
      nixosModules = import ./modules/nixos;

      overlays = import ./overlays;

      legacyPackages = forAllSystems (
        system: import ./default.nix {
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
            };
          };
        }
      );
      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs
          (_: v: nixpkgs.lib.isDerivation v)
          self.legacyPackages.${system}
      );
    };
}
