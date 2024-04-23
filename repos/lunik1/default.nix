{ pkgs ? import <nixpkgs> { } }:

with pkgs;

{
  amazing-marvin = callPackage ./pkgs/amazing-marvin { };
  bach = callPackage ./pkgs/bach { };
  efficient-compression-tool = callPackage ./pkgs/efficient-compression-tool { };
  feishin-appimage = pkgs.lib.warn "removed, please use the feishin nixpkgs package" (callPackage ./pkgs/feishin-appimage { });
  fsrcnnx-x2-8-0-4-1 = callPackage ./pkgs/mpv-shaders/fsrcnnx { variant = "8-0-4-1"; };
  fsrcnnx-x2-16-0-4-1 = callPackage ./pkgs/mpv-shaders/fsrcnnx { variant = "16-0-4-1"; };
  krig-bilateral = callPackage ./pkgs/mpv-shaders/krig-bilateral { };
  ls-colors = callPackage ./pkgs/ls-colors { };
  ssim-downscaler = callPackage ./pkgs/mpv-shaders/ssim-downscaler { };
  ssim-super-res = callPackage ./pkgs/mpv-shaders/ssim-super-res { };
  thumbfast = callPackage ./pkgs/mpv-scripts/thumbfast { };
  xcompose = callPackage ./pkgs/xcompose { };
  myosevka = lib.recurseIntoAttrs (callPackage ./pkgs/myosevka/default.nix { });
}
