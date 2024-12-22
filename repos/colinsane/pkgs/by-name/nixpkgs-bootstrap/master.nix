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
  rev = "9d61fbb6e2656858a1b458b1e399cba67274e8f1";
  sha256 = "sha256-+IPfdpTXcDx6uGG7EBMl27KuSDxtFPMX3koIJS83KuY=";
  version = "0-unstable-2024-12-21";
  branch = "master";
}
