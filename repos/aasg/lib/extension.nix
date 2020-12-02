{ lib }:
/*
 * Merge of the Nixpkgs and aasg libs.
 */
let
  aasgLib = import ./. { inherit lib; };
in
aasgLib.updateNewRecursive lib aasgLib
