# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "25f416a2a67f48ab36d9482e57339fdba1a13090";
  sha256 = "sha256-bDa7S1EH5orZZ7VWOQIlT22Bpw6/QtrfLC6zyCJJYb8=";
  version = "unstable-2026-06-22";
  branch = "master";
}
