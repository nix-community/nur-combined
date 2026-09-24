{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "4faa76a1b36aa652128c8337a7520010612b8b00";
  sha256 = "sha256-LCRZ1I9WQsYkZ0rlgLzwlJACyTIvInTuy8Y9fUXFoC4=";
  version = "unstable-2026-09-22";
  branch = "staging-next";
}
