# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "cb01d0b57f0259c96ea24aadac8892fb2c4de9d9";
  sha256 = "sha256-qTIRJScj1snNusZ0VBKmPvW8ChxxCSO00uC50Q9qkLg=";
  version = "unstable-2026-10-03";
  branch = "master";
}
