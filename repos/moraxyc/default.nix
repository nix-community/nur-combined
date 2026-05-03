{
  pkgs ? import <nixpkgs> { },
  ...
}@args:
(import ./pkgs/top-level/default.nix args).__nurPackages
