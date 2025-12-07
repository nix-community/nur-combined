{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "8144fe4b016b5b947b342a872d52b94e56e055c7";
  sha256 = "sha256-WQrCa+TxHlm6DDE/L5ychU1l+5T8+Tiic7Wi1w08LLE=";
  version = "unstable-2025-12-07";
  branch = "staging-next";
}
