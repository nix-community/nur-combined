let
  pkgs      = import <nixpkgs> {};
  gridTests = import ./grid.nix { inherit pkgs; };

in pkgs.lib.runTests gridTests
