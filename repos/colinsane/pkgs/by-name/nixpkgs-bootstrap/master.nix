# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
#
# if that fails, then:
# - set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got:  sha256:xyz`
# - nix hash to-sri sha256:xyz
#   - paste the output as the new `sha256`
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "62c0c99b63b83b09b4b6eb29e5bad169628a6f37";
  sha256 = "sha256-BevamVLXhjKQBXa9KVy8fvolcO9Tmoni6edGRcfdXm4=";
  version = "unstable-2025-05-29";
  branch = "master";
}
