# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "746b8efb34046d34c265626788832b76b7699067";
  sha256 = "sha256-VeWB3PjXgFMU86hvpZXymfSAZv+T9+KgtEjaZGF1Ckk=";
  version = "unstable-2026-06-18";
  branch = "master";
}
