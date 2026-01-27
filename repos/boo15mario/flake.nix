{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      treefmt-nix,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      pkgsDir = "${self}/pkgs";
      libDir = "${self}/lib";
      overlaysDir = "${self}/overlays";
      modulesDir = "${self}/modules";
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        config,
        withSystem,
        moduleWithSystem,
        ...
      }:
      let
        ourLib = (import libDir { inherit lib; });
        lib' = lib.recursiveUpdate lib ourLib;
      in
      {
        imports = [
          treefmt-nix.flakeModule
        ];
        flake = {
          lib = ourLib;
          overlays = lib'.importDirRecursive overlaysDir;
          modules = lib'.importDirRecursive modulesDir;
        };
        systems = lib.systems.flakeExposed;
        perSystem =
          {
            self',
            config,
            pkgs,
            ...
          }:
          let
            pkgs' = lib.recursiveUpdate pkgs { lib = lib'; };
            ourPackages = lib'.callDirPackageWithRecursive pkgs' pkgsDir;
          in
          {
            legacyPackages = ourPackages // {
              inherit (self) lib overlays modules;
              maintainers = pkgs.callPackage "${self}/maintainers" { };
            };
            packages = lib.filterAttrs (_: lib.isDerivation) ourPackages;

            treefmt = {
              projectRootFile = "flake.nix";
              programs.nixfmt.enable = true;
              programs.black.enable = true;
              programs.yamlfmt.enable = true;
              programs.mdformat.enable = true;
            };
          };
      }
    );
}
