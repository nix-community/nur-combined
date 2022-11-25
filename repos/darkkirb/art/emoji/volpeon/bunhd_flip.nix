{callPackage}:
callPackage ../../../lib/mkPleromaEmoji.nix {} rec {
  name = "bunhd_flip";
  manifest = ./bunhd.json;
  configurePhase = ''
    rm a*.png
  '';
}
