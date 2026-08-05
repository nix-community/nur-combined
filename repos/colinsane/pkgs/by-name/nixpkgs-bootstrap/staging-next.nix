{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "8da2a7077fef1b89fbfae06c59f4384f66119b51";
  sha256 = "sha256-Q8nQO2uIdlFSBtFiDyIWL2J6j4/9HjtUkBs/Pc4SK4Q=";
  version = "unstable-2026-08-01";
  branch = "staging-next";
}
