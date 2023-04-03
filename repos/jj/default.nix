{  pkgs ? import <nixpkgs> {} }: {

  freefem = pkgs.callPackage ./pkgs/freefem {};
}
