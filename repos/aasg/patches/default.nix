{ pkgs }:
let
  # self is not included here to avoid recursion.
  callPackage = pkgs.lib.callPackageWith pkgs;
  self = rec {

    haunt = callPackage ./haunt { };

  };
in
self
