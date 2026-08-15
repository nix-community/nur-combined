{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "5dc26c42403345c0d42019ada961f3a5be7d3b9c";
  sha256 = "sha256-g9WheFNljSwqpMoaUJykSY0Zw+2BOTxIncCY5xEbcfs=";
  version = "unstable-2026-08-12";
  branch = "staging-next";
}
