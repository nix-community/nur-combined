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
  rev = "4b4e56e716bcbc0ec342ae39f3f14d585e6b26fa";
  sha256 = "sha256-SXLZwWpBrhVbykeaeWvUFvwK7COTWl0h9lInGtjdqKQ=";
  version = "unstable-2025-05-19";
  branch = "master";
}
