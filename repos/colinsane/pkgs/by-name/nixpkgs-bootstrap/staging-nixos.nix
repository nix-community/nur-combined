{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "03037f95e2817ad09babafa8c0c40c938f435877";
  sha256 = "sha256-M/rX3uQ3/trpfXSSkVP3ULiq5H1PKpJu/pTMLc3tSuY=";
  version = "unstable-2026-11-19";
  branch = "staging-nixos";
}
