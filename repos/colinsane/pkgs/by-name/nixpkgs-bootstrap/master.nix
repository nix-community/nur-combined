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
  rev = "852ff1d9e153d8875a83602e03fdef8a63f0ecf8";
  sha256 = "sha256-Zf0hSrtzaM1DEz8//+Xs51k/wdSajticVrATqDrfQjg=";
  version = "0-unstable-2025-01-26";
  branch = "master";
}
