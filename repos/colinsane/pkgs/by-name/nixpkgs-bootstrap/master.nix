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
  rev = "f0c2751b5e11520e29549adc1563ba1fc1e759fe";
  sha256 = "sha256-CCzIhf4yt9INU/sPRVMLzg5gOzkekQ1KWzNcKbj1BxQ=";
  version = "0-unstable-2025-01-01";
  branch = "master";
}
