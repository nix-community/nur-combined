{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "9dabdba62a9ef450d065c7b3db97289040f9b1b4";
  sha256 = "sha256-058P51VyT7c8C/5RvHnXtA/6dfrEiLrizMz55kVtz5E=";
  version = "unstable-2025-12-12";
  branch = "staging";
}
