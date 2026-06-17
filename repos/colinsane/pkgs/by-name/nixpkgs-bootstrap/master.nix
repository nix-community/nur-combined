# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "b38530584b29cc6adb99ed995efd30d4fc9fa2d2";
  sha256 = "sha256-lJjo01/K+l7IgHdsxv7mZd/CcGcIYAk5mmwf+ElGOfc=";
  version = "unstable-2026-06-16";
  branch = "master";
}
