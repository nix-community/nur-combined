{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "d8eae6e977f18af4dd76361eaa7a7b3201db75d0";
  sha256 = "sha256-eyaqw1CAf6bnT2iZaXYZ1Sh4Q5yPbRTCijEQ4w8d7rI=";
  version = "unstable-2025-12-11";
  branch = "staging";
}
