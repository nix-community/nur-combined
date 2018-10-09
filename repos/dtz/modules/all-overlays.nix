{ ... }:

let
  lib = import ../lib;
in {
  nixpkgs.overlays = builtins.attrValues (lib.importDirectory ../overlays);
}
