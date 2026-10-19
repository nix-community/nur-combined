# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "f4773c1063daa8b60b8716b7a2c3523883703a5a";
  sha256 = "sha256-8Olb3P9Ns87zOsQ+M02zxgU28Mh3c/gKwYC57aruVmw=";
  version = "unstable-2026-10-18";
  branch = "master";
}
