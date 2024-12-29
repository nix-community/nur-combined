# to fix sha256 (in case the updater glitches):
# - set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got:  sha256:xyz`
# - nix hash to-sri sha256:xyz
#   - paste the output as the new `sha256`
{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "788f5d7711e9d6ac73bdba4935644a6c46eaaef8";
  sha256 = "sha256-SJAuYWg7vRfrMPnFE6KAcNHHU7gz5o/wrKoLJ9AOYDI=";
  version = "0-unstable-2024-12-29";
  branch = "master";
}
