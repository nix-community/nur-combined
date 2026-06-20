# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "21219862791c31fc78a63b1f3aeee2c8a64e739a";
  sha256 = "sha256-6xinizsvpmbkAdwGjLPDsDT7m64Ap3N1bpLRQmtENCg=";
  version = "unstable-2026-06-19";
  branch = "master";
}
