# to fix sha256 (in case the updater glitches):
# - set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got:  sha256:xyz`
# - nix hash to-sri sha256:xyz
#   - paste the output as the new `sha256`
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "f90d0a338d95120763afc3ba43410ba3391ad77b";
  sha256 = "sha256-fCsKB91aNDC7I5LgM5KGxlfJdhEbta5WrYxQmnPL1X4=";
  version = "0-unstable-2025-04-03";
  branch = "master";
}
