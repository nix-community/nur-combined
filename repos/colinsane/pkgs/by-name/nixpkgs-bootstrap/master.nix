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
  rev = "21e994c142b81b11ea2a69da638ec7b2f5903f0f";
  sha256 = "sha256-JgV+xqmaM+cay4zfv5KwVsVI4BurLZ7R5eledVT8mz0=";
  version = "0-unstable-2025-01-05";
  branch = "master";
}
