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
  rev = "b04bc354ce84af48baead53372c66bdc7f0db1a3";
  sha256 = "sha256-/q5imfCnkog54fjcJDelT8SrHMzidUU//oLZSkIMCPU=";
  version = "0-unstable-2025-01-27";
  branch = "master";
}
