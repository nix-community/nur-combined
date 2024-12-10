{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "14a523cc30a1a68cebfc1150bb179d2af88a9715";
  sha256 = "sha256-S0KkPonXrFfoNkBDM/Ptus4JSLK37CGG0JlLAr8uR/I=";
  version = "0-unstable-2024-12-09";
  branch = "staging";
}
