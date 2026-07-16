# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "6b0007bb6a29c1290cff03768bf5e52cebcb4bd3";
  sha256 = "sha256-u1sVZkLHENdtOcphE3ifQL0dgR/RMb7/1wtQHK7OhkU=";
  version = "unstable-2026-07-15";
  branch = "master";
}
