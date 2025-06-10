{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      dc-lib = import ./lib { inherit (nixpkgs) lib; };
    in
    rec {
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      });

      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});

      lib = dc-lib;

      overlays = import ./overlays;

      nixosModules = builtins.listToAttrs (
        map (m: {
          name = m;
          value = import (./modules + "/${m}");
        }) (dc-lib.listSubdirNames ./modules)
      );

      modules = nixosModules;

      hmModules = builtins.listToAttrs (
        map (m: {
          name = m;
          value = import (./hmModules + "/${m}");
        }) (dc-lib.listSubdirNames ./hmModules)
      );

      # devShells = forAllSystems (system: let
      #   pkgs = import nixpkgs { inherit system; };
      # in {
      #   default = pkgs.mkShell {
      #     packages = with pkgs; [
      #       nix-update
      #     ];
      #   };
      # });
    };
}
