# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "a134127b7aa6d062fa3cada459b5886f0233a965";
  sha256 = "sha256-HQu8SoQzJfV6mm99VoIHW0Rxo5Fffn9jkc8w77zzK9Y=";
  version = "unstable-2026-08-04";
  branch = "master";
}
