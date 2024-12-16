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
  rev = "21d7df2cae8e141691e863aa54b75ca82c946afd";
  sha256 = "sha256-9Kbey0pZmGE/VRXssGtKDrI/p+uZSOthpNz5gImMlP0=";
  version = "0-unstable-2024-12-16";
  branch = "master";
}
