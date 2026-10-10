# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "7c54a836d5ac44fa642d5a1093ab046e56268a7b";
  sha256 = "sha256-V45nDCdLP8umcKPM/mPQZH6JSundPEa5L/Nxp6rRuJI=";
  version = "unstable-2026-10-09";
  branch = "master";
}
