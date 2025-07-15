{ pkgs ? import <nixpkgs> { } }:
{
  apple-fonts = pkgs.callPackage ./pkgs/apple-fonts { inherit pkgs; };
  Win10_LTSC_2021_fonts = pkgs.callPackage ./pkgs/Win10_LTSC_2021_fonts { };
}
