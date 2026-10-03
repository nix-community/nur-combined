# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "ccf5062511e30e3a56c6693d7b09ab58608d204f";
  sha256 = "sha256-rt8HfJxb3QYOG3oonWplGZCjCH2q+mmXM5ILOPDY7+Q=";
  version = "unstable-2026-10-03";
  branch = "master";
}
