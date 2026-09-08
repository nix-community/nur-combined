# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "173576c244843915f940b897f9a3c9eca8b7238b";
  sha256 = "sha256-RXvE2Qhjr9Sfump+JjoGq4e8NKzTCkT1SE9nMPWwVu0=";
  version = "unstable-2026-09-07";
  branch = "master";
}
