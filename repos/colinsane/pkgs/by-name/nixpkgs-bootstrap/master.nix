# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "33e947821beb824d670b6c943b53fd1611f27a8e";
  sha256 = "sha256-LE//V/jYGgoOqdlNdXEfOQINdE0peHVv0IdbF66zTNU=";
  version = "unstable-2026-06-14";
  branch = "master";
}
