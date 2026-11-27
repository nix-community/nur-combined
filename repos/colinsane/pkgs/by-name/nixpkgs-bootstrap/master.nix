# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "c469b1143f4cb3921ca74ab5ac77ea9ac0c7ca9f";
  sha256 = "sha256-Zr59OeEwUYl5rk+AeFYZijeC+7n/OLHWQBp38hlAEd0=";
  version = "unstable-2026-11-26";
  branch = "master";
}
