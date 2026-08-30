# NUR (Nix User Repository) package exports
# See: https://nur.nix-community.org/documentation/
{pkgs}: {
  antigravity-tools-bin = pkgs.callPackage ./antigravity-tools-bin {};
  openfortigui = pkgs.callPackage ./openfortigui {};
  orca-bin = pkgs.callPackage ./orca-bin {};
  prince-bin = pkgs.callPackage ./prince-bin {};
  zed-preview-bin = pkgs.callPackage ./zed-preview-bin {};
}
