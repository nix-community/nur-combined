{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        # "i686-linux"
        # "x86_64-darwin"
        # "aarch64-linux"
        # "armv6l-linux"
        # "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});

      overlay = final: prev: {
        septimalmind = import ./default.nix {
          pkgs = prev;
        };
      };
      nixosModules.septimalmind =
        { lib, pkgs, ... }:
        {
          options.septimalmind = lib.mkOption {
            type = lib.mkOptionType {
              name = "septimalmind";
              description = "An instance of the 7mind Nix repository";
              check = builtins.isAttrs;
            };
            description = "Use this option to import packages from 7mind repository";
            default = import self {
              pkgs = pkgs;
            };
          };
        };
    };
}
