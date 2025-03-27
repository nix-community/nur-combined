# to fix sha256 (in case the updater glitches):
# - set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got:  sha256:xyz`
# - nix hash to-sri sha256:xyz
#   - paste the output as the new `sha256`
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "badeba75aa01faa7c323beecd4557c840480add6";
  sha256 = "sha256-MGRa2w0ejQCcF4IMR6Mpvgu1lh8XjHF+Po0DO1kLtWo=";
  version = "0-unstable-2025-03-24";
  branch = "master";
}
