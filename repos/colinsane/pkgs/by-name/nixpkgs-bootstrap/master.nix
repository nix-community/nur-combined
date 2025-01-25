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
  rev = "a30e6ed47d894b55364a43c666c582f3b976acff";
  sha256 = "sha256-C0RWATTKrPwM2PoJbKlyuk0cr/JzxRhAIvi1y49+52Y=";
  version = "0-unstable-2025-01-25";
  branch = "master";
}
