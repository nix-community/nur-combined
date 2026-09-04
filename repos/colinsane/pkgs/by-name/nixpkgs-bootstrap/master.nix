# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "5fca99feb07a88140cde3e91dfb3da7886830e11";
  sha256 = "sha256-W6IkK/+oWinFNqd6ZJFMdzGI3FN4Gg2jhr8kzi4xZi0=";
  version = "unstable-2026-09-04";
  branch = "master";
}
