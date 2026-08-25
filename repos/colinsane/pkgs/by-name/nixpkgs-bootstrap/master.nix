# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "5393532ca53514c3abac520daaba58b30ff8474b";
  sha256 = "sha256-w9sekYpHG5jDKIcfwiZaGb1hKusx/LZLqFCy2GXcN7A=";
  version = "unstable-2026-08-24";
  branch = "master";
}
