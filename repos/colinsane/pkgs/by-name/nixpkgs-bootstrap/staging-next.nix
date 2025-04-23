{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "18864fbb484cab61752d045fb7387240b5a7f44c";
  sha256 = "sha256-JUH/2dyE0PYnHkHLtkRzv85N2ikcnlwFLHm3orgQuU8=";
  version = "0-unstable-2025-04-23";
  branch = "staging-next";
}
