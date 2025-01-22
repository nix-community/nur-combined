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
  rev = "f7b9530368d3de85836c112f48df56e9beb01a48";
  sha256 = "sha256-FYV5DPU1X6M15h4UrvbXP9Ep1CWh7gmgVpe2lMzD4Y4=";
  version = "0-unstable-2025-01-21";
  branch = "master";
}
