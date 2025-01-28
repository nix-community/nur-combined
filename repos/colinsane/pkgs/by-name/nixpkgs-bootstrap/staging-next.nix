{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "b6f676fbd2c31ad426f9ef245edf840019313d20";
  sha256 = "sha256-JKDQb6jzpA8g5Mh7ZjKOUbDcgVkuYtgscXZzx1Zpu4s=";
  version = "0-unstable-2025-01-27";
  branch = "staging-next";
}
