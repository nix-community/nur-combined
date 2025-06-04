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
  rev = "1c0fb5eb567abaa9bc7085d681c6d46cd6c2344c";
  sha256 = "sha256-Hztlw3ByEmwpEcLhap7aqFT+HGs4t6VYkIB+5usDvtg=";
  version = "unstable-2025-06-04";
  branch = "master";
}
