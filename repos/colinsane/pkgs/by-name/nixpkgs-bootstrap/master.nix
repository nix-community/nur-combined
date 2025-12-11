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
  rev = "6417c1f8f4ab33d751458a93e7767992b31033cd";
  sha256 = "sha256-9AUJ5Ehsp9NrN75ye/arI5+In/TclZq3ESbdWjFSec4=";
  version = "unstable-2025-12-11";
  branch = "master";
}
