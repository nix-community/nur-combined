# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "3fc5466a3ad2472fa2b023615fb030909bb0956b";
  sha256 = "sha256-V6EoouwNH+WFA6Ud9quPxeS5gCLvgesipDfiITINkx0=";
  version = "unstable-2026-06-25";
  branch = "master";
}
