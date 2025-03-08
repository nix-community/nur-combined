{
  description = "Danil Suetin personal NUR repository";

  inputs = {
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

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
      flake-utils,
      treefmt-nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystemPassThrough (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in
      {
        # `nix fmt`
        formatter.${system} = treefmtEval.config.build.wrapper;

        # `nix flake check`
        checks.${system} = {
          formatting = treefmtEval.config.build.check self;
        };

        legacyPackages.${system} = import ./default.nix { inherit pkgs; };

        packages.${system} = flake-utils.lib.flattenTree self.legacyPackages.${system};
      }
    );
}
