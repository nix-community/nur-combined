{
  pkgs,
}:

let
  lib' = import ./lib {
    inherit lib' pkgs;
    inherit (pkgs) lib;
  };
in
lib'
