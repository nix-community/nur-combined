{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
let
  libs = import ../libs {
    inherit system pkgs;
  };
in
rec {
  bobgen = pkgs.callPackage ./bobgen { };
  bobgen-unstable = pkgs.callPackage ./bobgen/unstable.nix { inherit bobgen; };
  bumper = pkgs.callPackage ./bumper { };
  catppuccin-zen-browser = pkgs.callPackage ./catppuccin-zen-browser { };
  fetch-hash = pkgs.callPackage ./fetch-hash { };
  ffmpeg-quality-metrics = pkgs.python3Packages.callPackage ./ffmpeg-quality-metrics { };
  flake-release = pkgs.callPackage ./flake-release { };
  gleescript = pkgs.callPackage ./gleescript { inherit (libs) gleam; };
  go-over = pkgs.callPackage ./go-over { inherit (libs) gleam; };
  nix-fix-hash = pkgs.callPackage ./nix-fix-hash { };
  nix-scan = pkgs.callPackage ./nix-scan { };
  opengrep = pkgs.python3Packages.callPackage ./opengrep { };
  protoc-gen-connect-openapi = pkgs.callPackage ./protoc-gen-connect-openapi { };
  pysentry = pkgs.callPackage ./pysentry { };
  qsvenc = pkgs.callPackage ./qsvenc { };
  renovate = pkgs.callPackage ./renovate { };
  shellhook = pkgs.callPackage ./shellhook { };
  uv-build = pkgs.python3Packages.callPackage ./uv-build { };
  yt-dlp = pkgs.python3Packages.callPackage ./yt-dlp { inherit yt-dlp-ejs; };
  yt-dlp-ejs = pkgs.python3Packages.callPackage ./yt-dlp/ejs.nix { };
}
