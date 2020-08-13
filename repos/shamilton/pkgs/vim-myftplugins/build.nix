#!/run/current-system/sw/bin/nix-build

let pkgs = import <nixpkgs> {};
in 
with pkgs;
callPackage (import ./default.nix) { }
