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
  rev = "a37ebead1785777bed04c56a029f099b85c957d2";
  sha256 = "sha256-AzH1rZFqEH8sovZZfJykvsEmCedEZWigQFHWHl6/PdE=";
  version = "0-unstable-2025-01-23";
  branch = "master";
}
