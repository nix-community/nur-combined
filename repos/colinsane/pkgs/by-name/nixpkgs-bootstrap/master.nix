# to fix sha256 (in case the updater glitches):
# - set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got:  sha256:xyz`
# - nix hash to-sri sha256:xyz
#   - paste the output as the new `sha256`
{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "fa648b2835f6cc0e77bd3b246cf8c80f126f0139";
  sha256 = "sha256-1Vg8DUmf9Re46lbjWq02IV0syQJLUO1y5CoUcWP5C/s=";
  version = "0-unstable-2025-02-08";
  branch = "master";
}
