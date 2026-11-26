# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "cd7b1a25c803cca507e19ceb4cade0616b4ae7b9";
  sha256 = "sha256-nHp1UYyP5LdUksj8rY76A1JTD4zVE43ThTbER52cFZI=";
  version = "unstable-2026-11-22";
  branch = "master";
}
