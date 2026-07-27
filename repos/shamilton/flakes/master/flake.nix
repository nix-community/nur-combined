{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/25.11";
    gomod2nix.url = "github:nix-community/gomod2nix/v1.7.0";
  };
  outputs = { self, nixpkgs, gomod2nix }:
    let
      systems = [
        "x86_64-linux"
        # "x86_64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    rec {
      legacyPackages = forAllSystems (system: import ../../default.nix {
        pkgs = import nixpkgs { inherit system; };
        inherit gomod2nix;
        nixosVersion = "master";
        localUsage = false;
      });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
      checks = packages;
    };
}
