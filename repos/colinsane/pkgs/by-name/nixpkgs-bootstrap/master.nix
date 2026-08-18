# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "ff8bda625367dd6a60cf9db078ee491bec73a375";
  sha256 = "sha256-fUIj9lXHXkWNT+LC/AU4zyxohozSx0+ZiV6FVNzPKcY=";
  version = "unstable-2026-08-16";
  branch = "master";
}
