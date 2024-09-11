{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    unstable.url = "nixpkgs/nixos-unstable";
  };
  
  outputs = { self, nixpkgs, unstable, ... }: 
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
    in {
    legacyPackages = forAllSystems (system: import ./default.nix {
      pkgs = import nixpkgs { inherit system; };
    });
    packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
    overlays.default = final: prev: {
      wasabi375 = import ./default.nix {
        wasabipkgs = prev;
        pkgs = prev;
      };
    };
    nixosModules.wasabi375 = { lib, pkgs, ... }: {
      options.wasabi375 = lib.mkOption {
        type = lib.mkOptionType {
          name = "wasabi375";
          description = "My custom package repository";
          check = builtins.isAttrs;
        };
        description = "Use this option to import packages from wasabi375";
        default = import self {
          wasabipkgs = pkgs;
          pkgs = pkgs;
        };
      };
    };
  };
}
