{ pkgs ? import <nixpkgs> {} }:
{
  U6143_ssd1306 = pkgs.callPackage ./U6143_ssd1306 {};
}
