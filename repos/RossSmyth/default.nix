{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) callPackage;
in
{
  jqjq = callPackage ./jqjq { };
  isle-portable = callPackage ./isle-portable { };
  cerberus = callPackage ./cerberus { };
}
