{ pkgs ? import <nixpkgs> { } }:

{
  # example-package = pkgs.callPackage ./pkgs/example-package { };
  sniffcraft = pkgs.callPackage ./pkgs/sniffcraft { };
  botcraft = pkgs.callPackage ./pkgs/botcraft { };
}
