# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "b20614f741a889576257ac22beb17c8f696a604c";
  sha256 = "sha256-sH6nVm9Y2diYcULvIWSrNcWy98CaSxMzEoVMExmK4uc=";
  version = "unstable-2026-08-25";
  branch = "master";
}
