# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "2b0d111160e8989e9f6475acc3e9aa2ffd461259";
  sha256 = "sha256-XRu0IsWnny33fx4s3i+HWl5SnHf3HraKygH/Pvb7wfk=";
  version = "unstable-2026-11-21";
  branch = "master";
}
