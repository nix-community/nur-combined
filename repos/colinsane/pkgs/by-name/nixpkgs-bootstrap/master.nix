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
  rev = "43aa730b8bd3ef88e9274962a0464760f1c8821c";
  sha256 = "sha256-0Gkxi8riDTWw3ascHOtz36d9dxjVYEJAyOmY8NIqqyE=";
  version = "unstable-2025-12-08";
  branch = "master";
}
