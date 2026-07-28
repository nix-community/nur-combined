{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system: let
    lib = nixpkgs.lib;
    pkgs = nixpkgs.legacyPackages.${system};

  in {
    packages = lib.filesystem.packagesFromDirectoryRecursive {
      inherit (pkgs) callPackage;
      directory = ./pkgs;
    };
  });
}

