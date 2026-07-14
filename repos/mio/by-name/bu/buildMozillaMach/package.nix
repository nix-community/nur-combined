{ callPackage }:
opts: callPackage (import ./inner.nix opts) { }
