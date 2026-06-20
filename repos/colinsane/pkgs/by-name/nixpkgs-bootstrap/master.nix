# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "f573bd3e152c551ffa295b00ed11076fbd31bf0a";
  sha256 = "sha256-ysRJQuKOvxcQ8KcYaKrsPPHkgtvTOdArA9FP2EzvldA=";
  version = "unstable-2026-06-20";
  branch = "master";
}
