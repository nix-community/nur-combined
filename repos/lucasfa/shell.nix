{
  pkgs ? import <nixpkgs> { },
}:
let
  libslimbook = pkgs.callPackage ./pkgs/libslimbook { };
in
pkgs.mkShell {
  packages = [ python-slimbook ];
}
