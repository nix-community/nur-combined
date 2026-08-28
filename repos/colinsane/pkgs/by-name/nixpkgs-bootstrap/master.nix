# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "926e3b459e47c19854376fdfce6172863391cea5";
  sha256 = "sha256-bLNmrOD0lwRYbBNlYETfwWWmawVIytZ8nHoDcXZlH6k=";
  version = "unstable-2026-08-28";
  branch = "master";
}
