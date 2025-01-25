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
  rev = "401ac2b03c8fa072b0a8a0c517ed196d9be6499d";
  sha256 = "sha256-2mNYOXUh7ZJxqiI4Bvt9XXUwTG6mWJRMi50yh23Vro4=";
  version = "0-unstable-2025-01-24";
  branch = "master";
}
