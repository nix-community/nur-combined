# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "169f1f0f1a46f22073add2fd6a75eacd424f5e82";
  sha256 = "sha256-H7gt2AZx/sqaEZDUg6LMba0DXDtGDfpR4vnsPokGN4k=";
  version = "unstable-2026-09-25";
  branch = "master";
}
