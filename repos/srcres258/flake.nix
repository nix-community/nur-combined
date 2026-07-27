{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    ieda.url = "github:srcres258/iEDA/own";
  };

  outputs = {
    self,
    nixpkgs,
    ieda
  }: let
    lock = builtins.fromJSON (builtins.readFile ./flake.lock);
    lockedIeda = lock.nodes.ieda.locked;
    iedaFlake = builtins.${"getFlake"} "github:${lockedIeda.owner}/${lockedIeda.repo}/${lockedIeda.rev}";
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    hasIeda = system: builtins.hasAttr system iedaFlake.packages && iedaFlake.packages.${system} ? default;
  in {
    legacyPackages = forAllSystems (system: import ./default.nix ({
      pkgs = import nixpkgs {
        inherit system;
        config.allowBroken = true;
        config.allowUnfree = true;
      };
    } // nixpkgs.lib.optionalAttrs (hasIeda system) {
      ieda = iedaFlake.packages.${system}.default;
    }));
    packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v:
      nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
  };
}
