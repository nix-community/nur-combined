# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "50123dbae72f8013b10f555b6010e01f9f68ef46";
  sha256 = "sha256-0mJCRqHvpphYQ/wMlVXvOK0OsnJfn8Ap1ZGRnwwy5Vk=";
  version = "unstable-2026-07-07";
  branch = "master";
}
