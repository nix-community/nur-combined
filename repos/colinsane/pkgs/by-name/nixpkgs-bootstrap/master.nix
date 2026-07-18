# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "32c3d7e13edfd2144e78087ac5a9291833657bdc";
  sha256 = "sha256-1rD9Wlrv0doF3qfr83d9Ttya+sfPwQ0JFz8WLXdoDYk=";
  version = "unstable-2026-07-18";
  branch = "master";
}
