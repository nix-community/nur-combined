# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "7a35d3db8300fddf9d210fdb3bee1d98e850d036";
  sha256 = "sha256-MEKyHjUOnLVYZwbhpVlzEYFk2RW2ib4qqdrBnR0YUxM=";
  version = "unstable-2026-09-28";
  branch = "master";
}
