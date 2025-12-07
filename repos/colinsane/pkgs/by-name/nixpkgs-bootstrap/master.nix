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
  rev = "7bae8f7ef21b20d474bd8e973148c8f1f723116d";
  sha256 = "sha256-vZNws837/HHRl2jVU23WIz8kaqCsuvheRbtYjPnHNH8=";
  version = "unstable-2025-12-07";
  branch = "master";
}
