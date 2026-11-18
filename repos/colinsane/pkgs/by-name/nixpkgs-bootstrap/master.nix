# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "8b8d742368efa2297d8a6be670addd13067a447d";
  sha256 = "sha256-SV9w7ORdSUSunFUzVYnIHNjhGxI7vdCGszvZfTnD4yI=";
  version = "unstable-2026-11-17";
  branch = "master";
}
