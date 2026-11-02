# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "6f2a675f0a798e1fed914d082f0f05e9adc8cdfd";
  sha256 = "sha256-TtosihH+bd9IYmDrHHKZmfKH8T7zi5akFjXjYgKQsdw=";
  version = "unstable-2026-11-01";
  branch = "master";
}
