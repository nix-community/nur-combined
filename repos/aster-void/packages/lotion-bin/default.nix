{pkgs}:
pkgs.callPackage ./package.nix {
  system = "aarch-darwin";
}
