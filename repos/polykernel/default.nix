{ pkgs ? import <nixpkgs> { } }:

{
  packages = {
    zig-master = pkgs.callPackage ./pkgs/zig { llvmPackages = pkgs.llvmPackages_14; };
    lorien = pkgs.callPackage ./pkgs/lorien { };
    waylock = pkgs.callPackage ./pkgs/waylock { };
    i3bar-river = pkgs.callPackage ./pkgs/i3bar-river { };
    levee = pkgs.callPackage ./pkgs/levee { };
    kickoff = pkgs.callPackage ./pkgs/kickoff { };
    wired-notify = pkgs.callPackage ./pkgs/wired-notify { };
  };
}
