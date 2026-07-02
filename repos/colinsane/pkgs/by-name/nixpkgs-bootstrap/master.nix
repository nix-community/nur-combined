# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "6b5ddf3ef95465ea182f39e4a22d42bc62d0104f";
  sha256 = "sha256-Z7ILmkDOitcWcMV567C0dRhI92OkNe31kZkRpU14gAo=";
  version = "unstable-2026-07-01";
  branch = "master";
}
