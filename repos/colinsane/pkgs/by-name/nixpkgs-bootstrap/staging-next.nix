{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "3229b90251d2626b3592cde136355f150a4de9dd";
  sha256 = "sha256-Wgq6Cj9EvDmmq/l/vw8gEx/RH43l5mqFGTxqMZ888oE=";
  version = "unstable-2026-06-25";
  branch = "staging-next";
}
