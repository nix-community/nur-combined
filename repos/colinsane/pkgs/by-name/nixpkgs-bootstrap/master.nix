# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
#
# if that fails, then:
# - set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got:  sha256:xyz`
# - nix hash to-sri sha256:xyz
#   - paste the output as the new `sha256`
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "ca5b7b0475aaf5b36bb40d88f1fc180a900617c4";
  sha256 = "sha256-bP1aEAPX7jRVDY7yvkSWTZZJOVqAiY3OWU2Kne3T3N4=";
  version = "unstable-2025-12-06";
  branch = "master";
}
