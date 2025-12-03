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
  rev = "3c38eca0432d31fdd5bf2d501e8c60cb174ab48c";
  sha256 = "sha256-vkAr4NU5LXccn5djLRxhTOB+FpxalDUjNygcV58djJo=";
  version = "unstable-2025-12-03";
  branch = "master";
}
