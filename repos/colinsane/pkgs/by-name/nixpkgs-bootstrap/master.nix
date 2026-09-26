# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "e03faf4b5a4436963275a349f7cf48fe92663d70";
  sha256 = "sha256-Cb55pYG5Ve7sVwrHr+5Pi5xkbJ0Y1ss+hgwDNZEaM/s=";
  version = "unstable-2026-09-26";
  branch = "master";
}
