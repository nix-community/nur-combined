# nix-build -E 'with import <nixpkgs> { }; callPackage ./fetchipfs-test.nix { }'

{ curl, stdenv }:

let
  fetchipfs = import ./fetchipfs { inherit curl stdenv; };
in

fetchipfs {
  ipfs = "bafybeiflkjt66aetfgcrgvv75izymd5kc47g6luepqmfq6zsf5w6ueth6y";
  sha256 = "0p8w97j6rxnackm14p9npbra5a82irdb50i80qjc0pfpzjk781dm";
}
