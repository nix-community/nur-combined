{ callPackage }:
rec {
  distance = callPackage ./distance.nix {};
  g2p-en = callPackage ./g2p-en.nix { inherit distance; };

}
