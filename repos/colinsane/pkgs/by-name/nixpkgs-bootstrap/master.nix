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
  rev = "6bbb7f091ae7fd7f3de15b6986407c74bcc1ee1b";
  sha256 = "sha256-BujCf9/N4XIF2QMrXkso99U3NlNnb+8xfgreGORKG9U=";
  version = "0-unstable-2024-12-15";
  branch = "master";
}
