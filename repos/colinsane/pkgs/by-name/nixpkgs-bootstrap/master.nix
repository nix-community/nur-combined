# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "22bd7614cd97dbaaa524e3328143c9dfd38a76ec";
  sha256 = "sha256-AR7aLqgTrsASbMNUwvD9LC7HaxYulpGZ5hEtBixqPpU=";
  version = "unstable-2026-06-12";
  branch = "master";
}
