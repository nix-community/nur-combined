# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "c80ebf028d790bbe8db2bebf80e10cf9f92739c0";
  sha256 = "sha256-O5Ul1f+Pk4krLnanTllKBofmHVZmcEdVWpL9J7bj6qk=";
  version = "unstable-2026-06-24";
  branch = "master";
}
