{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
      nixpkgsForSystem = system: import nixpkgs { inherit system; };
      treefmtBuild = pkgs: (treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build;
    in
    {
      legacyPackages = forAllSystems (system: import ./default.nix { pkgs = nixpkgsForSystem system; });

      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
      );

      checks = forAllSystems (system: {
        formatting = (treefmtBuild (nixpkgsForSystem system)).check self;
      });

      formatter = forAllSystems (system: (treefmtBuild (nixpkgsForSystem system)).wrapper);
    };
}
