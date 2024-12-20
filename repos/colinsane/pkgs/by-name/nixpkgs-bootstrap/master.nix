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
  rev = "a01b0bf2fe47fc48c5faae6bd7cd2565024c6889";
  sha256 = "sha256-WzfZbADLsSvmAoMvr25COFsfCngqhsirHwqq+noQ4kw=";
  version = "0-unstable-2024-12-20";
  branch = "master";
}
