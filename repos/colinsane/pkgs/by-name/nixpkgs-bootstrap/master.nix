# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "2b4e30ae1208b0b509e11aff4f3b2746e6f58b3c";
  sha256 = "sha256-fEJ/RKAPRHqYFfvMtuNQc7ypmGt9hWycqcMQ2XeH9tM=";
  version = "unstable-2026-07-29";
  branch = "master";
}
