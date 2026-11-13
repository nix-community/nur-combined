# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "e174f414f03383fe69fa8c519596dd2f6279a2ce";
  sha256 = "sha256-aIx+AI/EU8sUJcmREx/SdkJL+6NwEgNcVduOeyS5nPk=";
  version = "unstable-2026-11-12";
  branch = "master";
}
