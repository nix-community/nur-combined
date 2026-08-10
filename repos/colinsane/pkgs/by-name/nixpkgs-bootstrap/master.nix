# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "fd9d47a04c10e84befb7fb5d9cf9808ca3c7ef9d";
  sha256 = "sha256-/qg82qBl7I7SVb8tmu8JZyasakhasEBH2GSiBY/zev8=";
  version = "unstable-2026-08-08";
  branch = "master";
}
