# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "04fdf0e855fe2fbb8265c4b55e91157b858d0be1";
  sha256 = "sha256-aABpzLYFldYBexYuGaqtGs9m8U8wyBYtGgpF6oEgGC4=";
  version = "unstable-2026-06-23";
  branch = "master";
}
