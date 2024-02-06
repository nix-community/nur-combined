{ pkgs }:
let inherit (pkgs) lib;
in lib.mapAttrs (name: ty: pkgs.callPackage ./${name}/package.nix { })
(lib.filterAttrs (name: ty: ty == "directory") (builtins.readDir ./.))
