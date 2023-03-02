{ pkgs, lib, callPackage }:

lib.foldr lib.recursiveUpdate { } [
  (import ./import.nix { inherit pkgs lib; })
  (import ./convert.nix { inherit pkgs lib callPackage; })
  { writeRustScript = import ./rust-script.nix { inherit pkgs; };  }
  { writeNpmPackage = import ./npm-package.nix { inherit pkgs; };  }
]
