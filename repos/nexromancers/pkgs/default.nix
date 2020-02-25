{ pkgs, libExtension }:

let

composeExtensionList = lib:
  let inherit (lib) composeExtensions foldl' head tail; in
  exts:
  if exts == [ ]
    then (self: super: { })
    else foldl' composeExtensions (head exts) (tail exts);

allPackages = import ./top-level/all-packages.nix;

in let p = pkgs'; pkgs' = pkgs.appendOverlays [
  (pkgs: super: { lib = super.lib.extend libExtension; })
]; in p.lib.makeScope p.newScope (scopedPkgs: (composeExtensionList p.lib [
  allPackages
]) scopedPkgs p)
