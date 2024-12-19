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
  rev = "d3c42f187194c26d9f0309a8ecc469d6c878ce33";
  sha256 = "sha256-cHar1vqHOOyC7f1+tVycPoWTfKIaqkoe1Q6TnKzuti4=";
  version = "0-unstable-2024-12-17";
  branch = "master";
}
