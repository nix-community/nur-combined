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
  rev = "ac24885fb5e9b15729a5fa78f14cfe159e5a86ec";
  sha256 = "sha256-1VeCNga84owW5OVFNTUM5pYAluXyKntwC3HNe2zgzvg=";
  version = "0-unstable-2025-01-28";
  branch = "master";
}
