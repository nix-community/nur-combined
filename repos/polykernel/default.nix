{ pkgs ? import <nixpkgs> { } }:

{
  packages = {
    zig-master = pkgs.callPackage ./pkgs/zig { llvmPackages = pkgs.llvmPackages_13; };
  };
}
