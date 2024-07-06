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
      nixosModules = import ./modules;
      # homeManagerModules = import ./modules/home;

      overlays = import ./overlays;

      legacyPackages = forAllSystems (
        system: import ./default.nix {
          pkgs = import nixpkgs { inherit system; };
        }
      );
      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs
          (_: v: nixpkgs.lib.isDerivation v)
          self.legacyPackages.${system}
      );
    };
}
