{pkgs}:
pkgs.callPackage ./package.nix {
  pnpm = pkgs.pnpm_10;
  nodejs = pkgs.nodejs_24;
}
