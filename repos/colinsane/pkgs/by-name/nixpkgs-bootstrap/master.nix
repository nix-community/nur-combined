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
  rev = "d0b337fdc81d07dfcf47a94b2167ab924071e7c9";
  sha256 = "sha256-u9w04EiWbW/YuR+sgsdyFK/N5ggOx4oZ38y+xoH/2Fc=";
  version = "unstable-2025-12-12";
  branch = "master";
}
