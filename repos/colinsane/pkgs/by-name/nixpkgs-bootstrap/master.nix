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
  rev = "77538077358d989c679cfb96c0d7774884e6d3ad";
  sha256 = "sha256-kGTjTJDMHurVesjcdEYyNntTSkpzWtraPlO1LLLd6c0=";
  version = "0-unstable-2025-01-18";
  branch = "master";
}
