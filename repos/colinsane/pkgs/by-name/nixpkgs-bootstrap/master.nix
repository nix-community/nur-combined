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
  rev = "c97cbc1c98e3515de6e61cff429def14b05399de";
  sha256 = "sha256-k6/x5I0VBqR0hMHPMRpF65RQyIbc6KIwixwgXO59cCE=";
  version = "0-unstable-2025-01-17";
  branch = "master";
}
