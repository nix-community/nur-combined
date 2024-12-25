# to fix sha256 (in case the updater glitches):
# - set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got:  sha256:xyz`
# - nix hash to-sri sha256:xyz
#   - paste the output as the new `sha256`
{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "9fe47b75ff7dca8f9b495379de7848ca64558a04";
  sha256 = "sha256-H0fUZRrhirugxEE2Ig1k7jMZ9wPKxseE+uFvtIccykM=";
  version = "0-unstable-2024-12-23";
  branch = "master";
}
