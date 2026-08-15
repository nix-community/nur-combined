{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "2c436f2d4a88bec4151deb0f1fcfe1b38891a9c6";
  sha256 = "sha256-P7IrDyzbm2bIAu3JogkvxC2lkxQmks53MpxTN0ERRm8=";
  version = "unstable-2026-08-12";
  branch = "staging";
}
