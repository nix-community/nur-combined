# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "a7a678191317d9010e8f417423eeb746fe49f1b2";
  sha256 = "sha256-9PCEEHz8Y16rliH1hpKWHaVEtCfYp8JljggsNGi9kI8=";
  version = "unstable-2026-08-21";
  branch = "master";
}
