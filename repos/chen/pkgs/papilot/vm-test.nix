{ pkgs ? import <nixpkgs> { } }:
let packages = pkgs.callPackage ./. { };
in import "${packages.source}/nix/vm-test.nix" { inherit pkgs; papilot = packages.default; }
