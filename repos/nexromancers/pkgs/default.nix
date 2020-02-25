{ pkgs, libExtension }:

let

allPackages = import ./top-level/all-packages.nix;

in let p = pkgs'; pkgs' = pkgs.appendOverlays [
  (pkgs: super: {
    lib = super.lib.extend libExtension;
    stdenv = super.stdenv // { lib = pkgs.lib; };
  })
]; in p.lib.makeScope p.newScope (scopedPkgs: (p.lib.composeExtensionList [
  allPackages
]) scopedPkgs p)
