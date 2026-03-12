{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
rec {
  bobgen = pkgs.callPackage ./bobgen { };
  bobgen-unstable = pkgs.callPackage ./bobgen/unstable.nix { inherit bobgen; };
  buf = pkgs.callPackage ./buf { inherit (pkgs) buf; };
  bumper = pkgs.callPackage ./bumper { };
  catppuccin-zen-browser = pkgs.callPackage ./catppuccin-zen-browser { };
  deno = pkgs.callPackage ./deno { inherit (pkgs) deno; };
  fetch-hash = pkgs.callPackage ./fetch-hash { };
  ffmpeg-quality-metrics = pkgs.python3Packages.callPackage ./ffmpeg-quality-metrics { };
  flake-release = pkgs.callPackage ./flake-release { };
  gleam = pkgs.callPackage ./gleam { };
  gleescript = pkgs.callPackage ./gleescript { inherit gleam; };
  go = pkgs.callPackage ./go { inherit (pkgs) go_latest; };
  go-over = pkgs.callPackage ./go-over { inherit gleam; };
  nix-fix-hash = pkgs.callPackage ./nix-fix-hash { };
  nix-scan = pkgs.callPackage ./nix-scan { };
  nvtop-exporter = pkgs.python3Packages.callPackage ./nvtop-exporter { };
  opengrep = pkgs.python3Packages.callPackage ./opengrep { };
  protoc-gen-connect-openapi = pkgs.callPackage ./protoc-gen-connect-openapi { };
  pysentry = pkgs.callPackage ./pysentry { };
  qsvenc = pkgs.callPackage ./qsvenc { };
  renovate = pkgs.callPackage ./renovate { };
  rust = pkgs.callPackage ./rust { inherit (pkgs) rust; };
  shellhook = pkgs.callPackage ./shellhook { };
  uv-build = pkgs.python3Packages.callPackage ./uv-build { };
  yt-dlp = pkgs.python3Packages.callPackage ./yt-dlp { inherit yt-dlp-ejs; };
  yt-dlp-ejs = pkgs.python3Packages.callPackage ./yt-dlp/ejs.nix { };
  zig-protobuf = pkgs.callPackage ./zig-protobuf { };
}
