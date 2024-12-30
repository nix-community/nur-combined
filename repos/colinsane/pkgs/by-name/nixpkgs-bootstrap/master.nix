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
  rev = "7dcdf9d94b96cc7f2e1726c79aa672ce4bcf824b";
  sha256 = "sha256-d4WLRw1ZPh2K9OAeNgDUvyzTfXScrSkAiJhjtX9VYYg=";
  version = "0-unstable-2024-12-30";
  branch = "master";
}
