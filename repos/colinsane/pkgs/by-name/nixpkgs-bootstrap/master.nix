# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "04be237269c4a43f72f5c5f2fb011bc8fe67eb8d";
  sha256 = "sha256-oAvvViuYlnkqbDFyS6KInZy3Z/gcXFgjjiMqZr+gzMs=";
  version = "unstable-2026-09-01";
  branch = "master";
}
