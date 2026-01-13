{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
{
  bobgen = pkgs.callPackage ./bobgen { };
  bumper = pkgs.callPackage ./bumper { };
  fetch-hash = pkgs.callPackage ./fetch-hash { };
  ffmpeg-quality-metrics = pkgs.callPackage ./ffmpeg-quality-metrics { };
  nix-fix-hash = pkgs.callPackage ./nix-fix-hash { };
  nix-flake-release = pkgs.callPackage ./nix-flake-release { };
  nix-scan = pkgs.callPackage ./nix-scan { };
  opengrep = pkgs.callPackage ./opengrep { };
  protoc-gen-connect-openapi = pkgs.callPackage ./protoc-gen-connect-openapi { };
  qsvenc = pkgs.callPackage ./qsvenc { };
  renovate = pkgs.callPackage ./renovate { };
  shellhook = pkgs.callPackage ./shellhook { };
}
