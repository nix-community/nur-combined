{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
let
  libs = import ../libs { inherit system pkgs; };
in
{
  bumper = pkgs.callPackage ./bumper { };
  bwrap-apprun = pkgs.pkgsStatic.callPackage ./bwrap-apprun { };
  catppuccin-gtk = pkgs.callPackage ./catppuccin-gtk { };
  catppuccin-zen-browser = pkgs.callPackage ./catppuccin-zen-browser { };
  chrome-devtools-mcp = pkgs.callPackage ./chrome-devtools-mcp { };
  codex-commit = pkgs.callPackage ./codex-commit { };
  duckdb = pkgs.callPackage ./duckdb { };
  fetch-hash = pkgs.callPackage ./fetch-hash { };
  fix-hash = pkgs.callPackage ./fix-hash { };
  flake-release = pkgs.callPackage ./flake-release { };
  gleescript = pkgs.callPackage ./gleescript { inherit (libs) gleamErlangHook gleamFetchDeps; };
  go-over = pkgs.callPackage ./go-over { inherit (libs) gleamErlangHook gleamFetchDeps; };
  helium = pkgs.callPackage ./helium { };
  igsc = pkgs.callPackage ./igsc { };
  libwtf = pkgs.callPackage ./libwtf { };
  nix-scan = pkgs.callPackage ./nix-scan { };
  protoc-gen-connect-openapi = pkgs.callPackage ./protoc-gen-connect-openapi { };
  pysentry = pkgs.callPackage ./pysentry { };
  qsvenc = pkgs.callPackage ./qsvenc { };
  renovate = pkgs.callPackage ./renovate { };
  shellhook = pkgs.callPackage ./shellhook { };
  type2-runtime = pkgs.pkgsStatic.callPackage ./type2-runtime { inherit (pkgs) nix-update-script; };
  xdg-desktop-portal-luminous = pkgs.callPackage ./xdg-desktop-portal-luminous { };
  zig-protobuf = pkgs.callPackage ./zig-protobuf { };
}
// import ./python.nix { pythonPackages = pkgs.python3Packages; }
