{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "e17bc04456c9c774ddbadab755bbffbe04a7cf81";
  sha256 = "sha256-jI8roifCBa5+G6CPbOULRc/sw7MZjTxcM5H0f7CSKDg=";
  version = "0-unstable-2024-11-22";
  branch = "staging";
}
