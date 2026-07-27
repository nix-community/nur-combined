{pkgs}:
pkgs.callPackage ./package.nix {
  nodejs = pkgs.nodejs_22;
}
