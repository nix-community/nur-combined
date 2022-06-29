{ pkgs ? import <nixpkgs> { } }:

{
  packages = {
    zig-master = pkgs.callPackage ./pkgs/zig { llvmPackages = pkgs.llvmPackages_13; };
    lorien = pkgs.callPackage ./pkgs/lorien { };
    waylock = pkgs.callPackage ./pkgs/waylock { };
    i3bar-river = pkgs.callPackage ./pkgs/i3bar-river { };
    levee = pkgs.callPackage ./pkgs/levee { };
  };
}
