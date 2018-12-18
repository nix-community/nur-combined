let
  fetchPinned = pin: builtins.fetchGit { inherit (pkgs.lib.importJSON (./pins + "/${pin}.json")) rev url; };
  pkgs        = import <nixpkgs> {};

  xinomorf     = fetchPinned "xinomorf";
  modules.anxt = fetchPinned "anxt";

in import xinomorf { inherit modules pkgs; }
