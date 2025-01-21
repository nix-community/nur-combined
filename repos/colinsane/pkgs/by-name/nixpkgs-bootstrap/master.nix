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
  rev = "77c9ec1f655bf0fa92bf19d93ca24425a25830c6";
  sha256 = "sha256-Gr9/B9nuNjaxLFmITlRH0Ua+G/Y/Kn8uKMmDiI5etrg=";
  version = "0-unstable-2025-01-20";
  branch = "master";
}
