# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "61a17b0d57f6e6135c2a663faa80caece828fa1f";
  sha256 = "sha256-C5PyyAXSRQosS5cGd1V3P0fDyU0sKk5VoWYvQ/ck7dk=";
  version = "unstable-2026-08-27";
  branch = "master";
}
