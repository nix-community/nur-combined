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
  rev = "fd15f0eb3cfa66f56c8188a7f865886e652a16f1";
  sha256 = "sha256-rizeOTMhSQ1SDYuuoJzHilsewNA9Mq6DQk/GO8+pfAA=";
  version = "0-unstable-2025-04-23";
  branch = "master";
}
