# NUR (Nix User Repository) package exports
# See: https://nur.nix-community.org/documentation/
# How to add a package: create a directory with a default.nix, then add it here as pkgs.callPackage ./your-pkg {};

{ pkgs }:
{
  antigravity-tools-bin = pkgs.callPackage ./antigravity-tools-bin {};
  openfortigui = pkgs.callPackage ./openfortigui {};
  prince-bin = pkgs.callPackage ./prince-bin {};
  zed-preview-bin = pkgs.callPackage ./zed-preview-bin {};
}
