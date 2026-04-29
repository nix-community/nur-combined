{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
let
  libs = import ../libs { inherit system pkgs; };
in
rec {
  bobgen = pkgs.callPackage ./bobgen { };
  bobgen-unstable = pkgs.callPackage ./bobgen/unstable.nix { inherit bobgen; };
  buf = pkgs.callPackage ./buf { inherit (pkgs) buf; };
  bumper = pkgs.callPackage ./bumper { };
  bwrap-apprun = pkgs.pkgsStatic.callPackage ./bwrap-apprun { };
  catppuccin-gtk = pkgs.callPackage ./catppuccin-gtk { };
  catppuccin-zen-browser = pkgs.callPackage ./catppuccin-zen-browser { };
  fetch-hash = pkgs.callPackage ./fetch-hash { };
  ffmpeg-quality-metrics = pkgs.python3Packages.callPackage ./ffmpeg-quality-metrics { };
  flake-release = pkgs.callPackage ./flake-release { };
  gleescript = pkgs.callPackage ./gleescript { inherit (libs) gleamErlangHook gleamFetchDeps; };
  go-over = pkgs.callPackage ./go-over { inherit (libs) gleamErlangHook gleamFetchDeps; };
  helium = pkgs.callPackage ./helium { };
  igsc = pkgs.callPackage ./igsc { };
  modal = pkgs.python3Packages.callPackage ./modal { inherit synchronicity; };
  nix-fix-hash = pkgs.callPackage ./nix-fix-hash { };
  nix-scan = pkgs.callPackage ./nix-scan { };
  nvtop-exporter = pkgs.python3Packages.callPackage ./nvtop-exporter { };
  opengrep = pkgs.python3Packages.callPackage ./opengrep { };
  protoc-gen-connect-openapi = pkgs.callPackage ./protoc-gen-connect-openapi { };
  pysentry = pkgs.callPackage ./pysentry { };
  qsvenc = pkgs.callPackage ./qsvenc { };
  renovate = pkgs.callPackage ./renovate { };
  shellhook = pkgs.callPackage ./shellhook { };
  synchronicity = pkgs.python3Packages.callPackage ./synchronicity { };
  type2-runtime = pkgs.pkgsStatic.callPackage ./type2-runtime { };
  uv-build-latest = pkgs.python3Packages.callPackage ./uv-build { };
  yt-dlp = pkgs.python3Packages.callPackage ./yt-dlp { inherit yt-dlp-ejs; };
  yt-dlp-ejs = pkgs.python3Packages.callPackage ./yt-dlp/ejs.nix { };
  zig-protobuf = pkgs.callPackage ./zig-protobuf { };
}
