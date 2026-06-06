# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "dae8751c745a3c4143c6630f98c2da3cb1ec8763";
  sha256 = "sha256-2Lq6H9vHu48MAmWDV5UnyqifT09uwt79gGem7K50hkg=";
  version = "unstable-2026-06-06";
  branch = "master";
}
