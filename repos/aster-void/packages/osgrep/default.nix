{pkgs}:
pkgs.callPackage ./package.nix {
  pnpm = pkgs.pnpm_9;
  nodejs = pkgs.nodejs_22;
}
