# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "c363a22e72f26aa7a9580126b32fe858f00fa68f";
  sha256 = "sha256-tw5Ln+jYysHjsWi+TudoOWgarSWncKMlzb/8W1cgGJM=";
  version = "unstable-2026-10-16";
  branch = "master";
}
