# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "c46dc20afad2a19cfc43552bc9447eddcb7b99af";
  sha256 = "sha256-BHPtsogJPrF41nG2ZQ0DOZ5os6qxG0LJPgblpSUjkUM=";
  version = "unstable-2026-07-04";
  branch = "master";
}
