{ pkgs }:
let mkGhc = pkgs.callPackage ./ghc.nix {};
    hashes = builtins.fromJSON (builtins.readFile ./hashes.json);
in
  builtins.mapAttrs (_: v: mkGhc v) hashes // { inherit mkGhc; }
