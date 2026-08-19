# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "0ba71a1e4f7ca9fa53341c076fed5818bb4ca04a";
  sha256 = "sha256-jHM4lm2OmFDW4A1CbHrcfb6hUBrwrPUH8XRBbd+3Mqk=";
  version = "unstable-2026-08-18";
  branch = "master";
}
