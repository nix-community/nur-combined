{pkgs, ...}: {
  mkPleromaEmoji = pkgs.callPackage ./mkPleromaEmoji.nix {};
  gradleDeps = pkgs.callPackage ./gradleDeps.nix {};
  opensslLegacyProvider = pkgs.callPackage ./opensslLegacyProvider.nix {};
}
