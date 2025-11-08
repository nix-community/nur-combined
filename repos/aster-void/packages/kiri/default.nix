{pkgs}:
pkgs.callPackage ./package.nix {
  pnpm = pkgs.pnpm_9;
  nodejs = pkgs.nodejs_22;
  python3 = pkgs.python3;
  pkgConfig = pkgs.pkg-config;
  cmake = pkgs.cmake;
  ninja = pkgs.ninja;
  which = pkgs.which;
}
