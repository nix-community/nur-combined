{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  inherit (pkgs.callPackage ./pkgs/lib { inherit pkgs; }) callPackage;
  modules = import ./modules;
in
{
  inherit modules;
}
// pkgs.lib.recurseIntoAttrs (callPackage ./pkgs { })
