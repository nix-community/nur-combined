# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "c824302f95819273ea1ea500d348229bf575a744";
  sha256 = "sha256-RpatG7Rgeqby/R4MXvypqMf9EowJZForE0oLod9ofPE=";
  version = "unstable-2026-11-06";
  branch = "master";
}
