# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "01d1e086f6b1ea59d70c887e90b16de66188d955";
  sha256 = "sha256-bu26snjNy/8dlIRAGuld7AXovBrjRGovWQey2rensl8=";
  version = "unstable-2026-06-11";
  branch = "master";
}
