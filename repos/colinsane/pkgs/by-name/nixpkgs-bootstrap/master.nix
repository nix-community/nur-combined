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
  rev = "10a75ab5b2c237e3c30556d65de3ee49ff4b6830";
  sha256 = "sha256-wn8eSx1dtapXJhpuaroc5W8mjlvuUDSBF2EOBSYE9hM=";
  version = "0-unstable-2025-01-02";
  branch = "master";
}
