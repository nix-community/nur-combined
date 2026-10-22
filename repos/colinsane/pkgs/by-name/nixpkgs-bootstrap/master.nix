# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "5c956803104532547987c2dd3d1ac5380bbcb5ca";
  sha256 = "sha256-KhUeFneAjlEMFt0f8Yxw5ds/n4VTtJLzVuhUS/ZoSR8=";
  version = "unstable-2026-10-19";
  branch = "master";
}
