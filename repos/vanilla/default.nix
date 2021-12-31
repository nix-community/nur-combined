{ pkgs ? import <nixpkgs> { } }:
{
  arknights-mower = pkgs.python39Packages.callPackage ./pkgs/arknights-mower { };
  fastfetch = pkgs.callPackage ./pkgs/fastfetch { };
  freshfetch = pkgs.callPackage ./pkgs/freshfetch { };
  gnome-text-editor = pkgs.callPackage ./pkgs/gnome-text-editor { };
  tdesktop-bin = pkgs.callPackage ./pkgs/tdesktop-bin { };
}
