{ pkgs ? import <nixpkgs> { } }:
{
  arknights-mower = pkgs.python39Packages.callPackage ./pkgs/arknights-mower { };
  fastfetch = pkgs.callPackage ./pkgs/fastfetch { };
  freshfetch = pkgs.callPackage ./pkgs/freshfetch { };
  gnome-text-editor = pkgs.callPackage ./pkgs/gnome-text-editor { };
  tdesktop-bin = pkgs.callPackage ./pkgs/tdesktop-bin { };

  apple-fonts = pkgs.callPackage ./pkgs/apple-fonts { inherit pkgs; };
  Win10_LTSC_2021_fonts = pkgs.callPackage ./pkgs/Win10_LTSC_2021_fonts { };
}
