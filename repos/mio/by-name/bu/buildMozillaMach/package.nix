{ callPackage }:
opts: callPackage (import ./default.nix opts) { }
