{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "b78e4ce9e1400876f45fe9d1ad52edade1b08671";
  sha256 = "sha256-cydHNoMfiCFIRNG88Tmip59M5gdza8/EUv2CAgvFIgI=";
  version = "unstable-2026-08-08";
  branch = "staging-next";
}
