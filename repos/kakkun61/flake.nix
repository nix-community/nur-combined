{
  description = "wd";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    wd = {
      url = "github:kakkun61/wd?ref=1.2.0&dir=linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    envar = {
      url = "github:kakkun61/envar?ref=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      treefmt-nix,
      flake-parts,
      wd,
      envar,
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports = [ treefmt-nix.flakeModule ];
        flake = { };
        systems = nixpkgs.lib.systems.flakeExposed;
        perSystem =
          { config, pkgs, ... }:
          {
            legacyPackages =
              import ./default.nix {
                inherit pkgs;
              }
              // {
                wd = wd.packages.${pkgs.stdenv.hostPlatform.system}.default;
              }
              // {
                envar = envar.packages.${pkgs.stdenv.hostPlatform.system}.default;
              };
            packages = nixpkgs.lib.filterAttrs (
              _: v: nixpkgs.lib.isDerivation v
            ) self.legacyPackages.${pkgs.stdenv.hostPlatform.system};
            devShells.default = pkgs.mkShell { };
            treefmt = {
              programs.nixfmt.enable = true;
            };
          };
      }
    );
}
