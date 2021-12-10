{ pkgs ? import <nixpkgs> { } }:
{
  fastfetch = pkgs.callPackage ./pkgs/fastfetch { };
  freshfetch = pkgs.callPackage ./pkgs/freshfetch { };
  gnome-text-editor = pkgs.callPackage ./pkgs/gnome-text-editor { };
  tdesktop-bin = pkgs.callPackage ./pkgs/tdesktop-bin { };
}
