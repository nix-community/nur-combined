# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "1efececa734469b8ccf794f461c7c22c4d1caa90";
  sha256 = "sha256-QUxU5yACARF3fquGaFdlxbBBYP1jaoPeDz2MBbZnOUo=";
  version = "unstable-2026-07-19";
  branch = "master";
}
