{
  pkgs ? import <nixpkgs> { },
  ...
}@args:
(import ./pkgs/default.nix args).__nurPackages
