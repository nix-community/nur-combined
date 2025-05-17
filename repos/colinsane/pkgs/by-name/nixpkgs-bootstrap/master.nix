# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
#
# if that fails, then:
# - set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got:  sha256:xyz`
# - nix hash to-sri sha256:xyz
#   - paste the output as the new `sha256`
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "d0e6be24d3d1a9eb8e26a6883ab7f3b1a9c5a0f7";
  sha256 = "sha256-0jCPNY7VtyQCIGpGpbhIHE2GjYJvQ+s3kv5PCkMSbVk=";
  version = "unstable-2025-05-15";
  branch = "master";
}
