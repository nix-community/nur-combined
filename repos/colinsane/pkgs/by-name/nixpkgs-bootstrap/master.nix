# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "3e1fd7f23d2427ca75a060f0bf738fdb1f3fd987";
  sha256 = "sha256-nKiDG3mPhR/VMNKFbR5Gi70tT6Gcrdzv2jp5e84IJ2w=";
  version = "unstable-2026-11-19";
  branch = "master";
}
