# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "00455b0a3690d3f5dc61e9aef4277dc86235b73f";
  sha256 = "sha256-kK3t7gwoz4Nx8RF46cs1Xz/skKNcK7y3KYP+gGqX6W8=";
  version = "unstable-2026-09-23";
  branch = "master";
}
