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
  rev = "e7e64b5141e943e44e5a9d6dc7e5b61e5d7971bc";
  sha256 = "sha256-ZJmtykBHOIMK5yT4mpWtnmDxj5wjgxfDvrr5sv3H8NA=";
  version = "0-unstable-2024-12-19";
  branch = "master";
}
