{ pkgs ? import <nixpkgs> { } }:

{
  amazing-marvin = pkgs.callPackage ./pkgs/amazing-marvin { };
  bach = pkgs.callPackage ./pkgs/bach { };
  fsrcnnx-x2-8-0-4-1 = pkgs.callPackage ./pkgs/mpv-shaders/fsrcnnx { variant = "8-0-4-1"; };
  fsrcnnx-x2-16-0-4-1 = pkgs.callPackage ./pkgs/mpv-shaders/fsrcnnx { variant = "16-0-4-1"; };
  krig-bilateral = pkgs.callPackage ./pkgs/mpv-shaders/krig-bilateral { };
  ssim-downscaler = pkgs.callPackage ./pkgs/mpv-shaders/ssim-downscaler { };
  ssim-super-res = pkgs.callPackage ./pkgs/mpv-shaders/ssim-super-res { };
  thumbfast = pkgs.callPackage ./pkgs/mpv-scripts/thumbfast { };
  xcompose = pkgs.callPackage ./pkgs/xcompose { };
}
