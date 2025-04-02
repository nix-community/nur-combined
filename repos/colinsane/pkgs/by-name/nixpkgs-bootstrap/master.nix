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
  rev = "99bb443ae33b5e0c0d6e2468797a58a398e175cf";
  sha256 = "sha256-RUyl8Wqp+MpQnRblzZE0qedTlrA4Grd6fxa0ysEAsIw=";
  version = "0-unstable-2025-04-02";
  branch = "master";
}
