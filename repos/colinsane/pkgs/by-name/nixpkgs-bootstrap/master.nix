# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "74ce8916b2eaaecb3d5dfe175f819893ff2510c2";
  sha256 = "sha256-ghphBugJYSIDeDNsyuc0xtH1uTxt7wse13l6z430Ng4=";
  version = "unstable-2026-10-10";
  branch = "master";
}
