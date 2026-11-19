# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "ac797115562aeed1a78222badbcbaff407b2f766";
  sha256 = "sha256-wfHB1cto+prGVK9sRq96lyactpvS/glJq27Y4mLNCTM=";
  version = "unstable-2026-11-19";
  branch = "master";
}
