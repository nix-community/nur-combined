{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;

{
  amazing-marvin = callPackage ./pkgs/amazing-marvin { };
  bach = callPackage ./pkgs/bach { };
  efficient-compression-tool = callPackage ./pkgs/efficient-compression-tool { };
  fsrcnnx-x2-8-0-4-1 = callPackage ./pkgs/mpv-shaders/fsrcnnx { variant = "8-0-4-1"; };
  fsrcnnx-x2-16-0-4-1 = callPackage ./pkgs/mpv-shaders/fsrcnnx { variant = "16-0-4-1"; };
  krig-bilateral = callPackage ./pkgs/mpv-shaders/krig-bilateral { };
  ls-colors = callPackage ./pkgs/ls-colors { };
  ssim-downscaler = callPackage ./pkgs/mpv-shaders/ssim-downscaler { };
  ssim-super-res = callPackage ./pkgs/mpv-shaders/ssim-super-res { };
  thelounge-theme-zenburn = callPackage ./pkgs/thelounge-theme-zenburn { };
  trash-d = callPackage ./pkgs/trash-d { };
  xcompose = callPackage ./pkgs/xcompose { };
  myosevka = lib.recurseIntoAttrs (callPackage ./pkgs/myosevka/default.nix { });
}
