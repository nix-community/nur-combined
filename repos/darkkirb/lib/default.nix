{pkgs, ...}: {
  mkPleromaEmoji = pkgs.callPackage ./mkPleromaEmoji.nix {};
  gradleDeps = pkgs.callPackage ./gradleDeps.nix {};
}
