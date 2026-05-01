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
  bumper = pkgs.callPackage ./bumper { };
  bwrap-apprun = pkgs.pkgsStatic.callPackage ./bwrap-apprun { };
  catppuccin-gtk = pkgs.callPackage ./catppuccin-gtk { };
  catppuccin-zen-browser = pkgs.callPackage ./catppuccin-zen-browser { };
  fetch-hash = pkgs.callPackage ./fetch-hash { };
  flake-release = pkgs.callPackage ./flake-release { };
  gleescript = pkgs.callPackage ./gleescript { inherit (libs) gleamErlangHook gleamFetchDeps; };
  go-over = pkgs.callPackage ./go-over { inherit (libs) gleamErlangHook gleamFetchDeps; };
  helium = pkgs.callPackage ./helium { };
  igsc = pkgs.callPackage ./igsc { };
  nix-fix-hash = pkgs.callPackage ./nix-fix-hash { };
  nix-scan = pkgs.callPackage ./nix-scan { };
  oxc-vscode = pkgs.callPackage ./oxc-vscode { };
  protoc-gen-connect-openapi = pkgs.callPackage ./protoc-gen-connect-openapi { };
  pysentry = pkgs.callPackage ./pysentry { };
  qsvenc = pkgs.callPackage ./qsvenc { };
  renovate = pkgs.callPackage ./renovate { };
  shellhook = pkgs.callPackage ./shellhook { };
  type2-runtime = pkgs.pkgsStatic.callPackage ./type2-runtime { };
  zig-protobuf = pkgs.callPackage ./zig-protobuf { };
}
// import ./python.nix { pythonPackages = pkgs.python3Packages; }
