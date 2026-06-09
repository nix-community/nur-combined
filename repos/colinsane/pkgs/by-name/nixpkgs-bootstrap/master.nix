# to fix sha256 (in case the updater glitches):
# - delete `sha256` or set `sha256 = "";`
# - nix-build -A hello
#   => it will fail, `hash mismatch ... got: sha256-xyz`
# - past that hash back into the `sha256` field
{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "0c3587ab1c380592ec2517a02e5761f4339d05f2";
  sha256 = "sha256-rQAcC0MxZPAeNEBpNCZj4cbuLjY6rPXPsn+lqxUOtHc=";
  version = "unstable-2026-06-09";
  branch = "master";
}
