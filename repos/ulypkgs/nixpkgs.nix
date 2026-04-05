# bootstrapping nixpkgs when we are not using flakes
# so we can use import (import ./nixpkgs.nix) instead of import <nixpkgs>
with (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
derivation {
  name = "source";
  system = builtins.currentSystem;
  builder = "/bin/sh";
  args = [
    "-c"
    "echo 'Run `nix flake archive` to fetch nixpkgs.' && exit 1"
  ];
  outputHashAlgo = "sha256";
  outputHash = narHash;
  outputHashMode = "recursive";
}
