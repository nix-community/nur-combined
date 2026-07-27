{pkgs}:
pkgs.callPackage ./package.nix {
  pnpm = pkgs.pnpm_10;
}
