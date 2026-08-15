# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "6ea9fcafeb1042f0f5e5a0d278cd88be9a2c921e";
  sha256 = "sha256-VyNdQETHJiBtyWAh7sp9RWSdQ5OxlScOZQ+aSG/pVfo=";
  version = "unstable-2026-08-13";
  branch = "master";
}
