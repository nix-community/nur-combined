{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs }:
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
        nixosVersion = "nixos-unstable";
        localUsage = false;
      });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
      checks = packages;
    };
}
