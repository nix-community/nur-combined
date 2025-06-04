{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "2c9e477cff34883ce6a42b56cae7bcb75cbbdd19";
  sha256 = "sha256-CNoAnqJWdl8PccShLPrHiwKuPIAumXX45T4XG6A5gT4=";
  version = "unstable-2025-06-04";
  branch = "staging-next";
}
