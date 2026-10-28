# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "b9dca90ef10c643257e003adbb377d588039ac1e";
  sha256 = "sha256-aUmTGOBaa3AHnU2g9t3b+Dl6mu6NwWojgNNeOVZwjWE=";
  version = "unstable-2026-10-26";
  branch = "master";
}
