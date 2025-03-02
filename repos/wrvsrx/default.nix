{
  pkgs ? import <nixpkgs> { },
}:
let
  overlay = import ./pkgs/overlay.nix;
  pkgs' = pkgs.extend overlay;
  getAllPackages =
    packageNames: packages:
    let
      toplevelPackageNames = packageNames._packageNames;
      nestPackageNames = pkgs.lib.attrsets.filterAttrs (
        name: value: name != "_packageNames"
      ) packageNames;
      toplevelPackages = pkgs.lib.attrsets.getAttrs toplevelPackageNames packages;
      nestPackages = pkgs.lib.attrsets.mapAttrs (
        nestName: nestPackageNames:
        pkgs.lib.recurseIntoAttrs (getAllPackages nestPackageNames packages.${nestName})
      ) nestPackageNames;
    in
    toplevelPackages // nestPackages;
in
getAllPackages pkgs'."nur-wrvsrx"._packageNames pkgs'
