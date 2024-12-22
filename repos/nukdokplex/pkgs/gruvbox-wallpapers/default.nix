{ callPackage, lib }:
(lib.attrsets.genAttrs [ "anime" "irl" "light" "minimalistic" "mix" "pixelart" "videogame-3d-art" ])
  (wallpapersCategory: callPackage ./category.nix { inherit wallpapersCategory; })
