{pkgs ? import <nixpkgs> {}}: let
    sources = pkgs.callPackage ./_sources/generated.nix {};
in
    pkgs.lib.packagesFromDirectoryRecursive {
        callPackage = pkgs.lib.callPackageWith (pkgs // {inherit sources;});
        directory = ./pkgs;
    }
