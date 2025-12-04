# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
#
# if that fails, then:
# - set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got:  sha256:xyz`
# - nix hash to-sri sha256:xyz
#   - paste the output as the new `sha256`
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "922f4336f99de9e3feaf65af6804cb850fd74089";
  sha256 = "sha256-l8DjjaJt8dYODtAY+PRAQwKdUwJpDaA4UNXRsKStQ+A=";
  version = "unstable-2025-12-04";
  branch = "master";
}
