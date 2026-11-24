{
  lib,
  nixpkgs,
}:

let
  lib' = import ./lib { inherit lib lib' nixpkgs; };
in
lib'
