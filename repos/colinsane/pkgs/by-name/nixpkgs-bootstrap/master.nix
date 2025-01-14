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
  rev = "9b8c09ebfa53fdd97faaa24046b50a809633b407";
  sha256 = "sha256-6epFUICq0orpPYEFZ5XFmBXalsQKDB9iRQ7XxHdsAnA=";
  version = "0-unstable-2025-01-14";
  branch = "master";
}
