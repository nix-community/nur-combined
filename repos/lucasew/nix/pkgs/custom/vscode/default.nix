{pkgs ? import <nixpkgs> {}, ...}:
let
  inherit (builtins) readDir filter attrNames map listToAttrs mapAttrs toPath replaceStrings;
  dirAttr = readDir ./.;
  dirNames = attrNames dirAttr;
  filteredFiles = filter (v: v != "default.nix") dirNames;
  premappedFiles = map (k: {name = (replaceStrings [".nix"] [""] k); value = null;}) filteredFiles;
  attrFilteredFiles = listToAttrs premappedFiles;
  attrImportedFiles = mapAttrs (k: v: pkgs.wrapVSCode { imports = [(./. + "/${k}.nix")]; }) attrFilteredFiles;
in attrImportedFiles
