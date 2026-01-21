{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    treefmt-nix,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;

    treefmtEval = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in
        treefmt-nix.lib.evalModule pkgs ./treefmt.nix
    );
  in {
    legacyPackages = forAllSystems (
      system:
        import ./default.nix {
          pkgs = import nixpkgs {inherit system;};
        }
    );
    packages = forAllSystems (
      system: let
        legacy = self.legacyPackages.${system};
        topLevel = nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) legacy;
        yaziPlugins = nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) legacy.yaziPlugins;
      in
        topLevel // {inherit yaziPlugins;}
    );

    formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);
    checks = forAllSystems (system: {
      formatting = treefmtEval.${system}.config.build.check self;
    });
  };
}
