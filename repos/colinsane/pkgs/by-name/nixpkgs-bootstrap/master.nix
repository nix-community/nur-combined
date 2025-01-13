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
  rev = "e7779f2efba6d57eaec78bf37e0e0f7c40a3298f";
  sha256 = "sha256-Yk54vu1/6oqdtkUkqY9kzRAshXx2HnX7NiJ9t6MVmLI=";
  version = "0-unstable-2025-01-13";
  branch = "master";
}
