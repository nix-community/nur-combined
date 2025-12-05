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
  rev = "2ec33b1c5c862b67e9f1115cbcc41983d44a2f88";
  sha256 = "sha256-v7AdCw+52pocKDaoaKqYhShT6EehcnDKl7qcfmvUQXU=";
  version = "unstable-2025-12-05";
  branch = "master";
}
