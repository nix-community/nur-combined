{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) lib;

  callPackage = pkgs.lib.customisation.callPackageWith (pkgs // { nur.repos.josh = pkgs'; });

  pkgs' = lib.attrsets.concatMapAttrs (_owner: lib.trivial.id) (
    lib.filesystem.packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./pkgs;
    }
  );
in
pkgs'
