# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "6f173c330b0fe1a22fd15cf5528538103f0b0a08";
  sha256 = "sha256-WVPEUiLTynpn2quV5A9tM/PNRpJzcxWY0nyOTjkb8zM=";
  version = "unstable-2026-11-14";
  branch = "master";
}
