# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "e130efaf39aa89f3cbed13b47dfa6003d9520b79";
  sha256 = "sha256-RUXuN1ZZPzMyYiMZEs+rX8bhDghAfnxVwV46XjOA55A=";
  version = "unstable-2026-07-05";
  branch = "master";
}
