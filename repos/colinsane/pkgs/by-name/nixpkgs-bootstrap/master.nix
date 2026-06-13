# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "2d88c278630eda415353378a9330b84a1e022048";
  sha256 = "sha256-5OusuQ+NJOuli2bKzUqBU7/TKmCa1+ak19FpkOcJF5c=";
  version = "unstable-2026-06-13";
  branch = "master";
}
