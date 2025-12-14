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
  rev = "f25fe72f5bdc77b666ce7c771d0afd5f138f8cd9";
  sha256 = "sha256-uAQ6U6gtbrtN4WhQ3iN9CnKbxziuyGRwgWdU9mE7TpM=";
  version = "unstable-2025-12-14";
  branch = "master";
}
