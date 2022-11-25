{callPackage}:
callPackage ../../../lib/mkPleromaEmoji.nix {} rec {
  name = "blobfox_flip";
  manifest = ./blobfox.json;
  configurePhase = ''
    rm a*.png
  '';
}
