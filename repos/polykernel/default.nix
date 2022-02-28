{ pkgs ? import <nixpkgs> { } }:

{
  packages = {
    zig-master = pkgs.callPackage ./pkgs/zig { llvmPackages = pkgs.llvmPackages_13; };
    lorien = pkgs.callPackage ./pkgs/lorien { };
    waylock = pkgs.callPackage ./pkgs/waylock { };
  };
}
