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
  rev = "113da45159c3ba1bedc9663e27d3174435db76bf";
  sha256 = "sha256-89Lu1Ja56N2waCTbFzVkTkuiJopA/RGacsGVq8iO3F0=";
  version = "0-unstable-2025-01-10";
  branch = "master";
}
