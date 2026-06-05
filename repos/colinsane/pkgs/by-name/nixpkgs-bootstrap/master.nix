# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "c45d6cdbe7ffaab404f2bb6e231b17b1b8ff5d5c";
  sha256 = "sha256-Lf8eywK7OPRaDBmbTxAnMWSmdoj1yOYGgKIwlWWBZI4=";
  version = "unstable-2026-06-05";
  branch = "master";
}
