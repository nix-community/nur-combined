# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "b2dbb5dbf7b9cd214e8d3ef4d33c791ff0de51cb";
  sha256 = "sha256-571xE/pW64qs3ZjWGfsNNXDJBgMyjJ2slZVq24CD1II=";
  version = "unstable-2026-09-24";
  branch = "master";
}
