{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "cfed72e3bbb241d3824d9c58a85515a5714962cf";
  sha256 = "sha256-FD4yHpv2BO9dPpzZLcNzyrqWC+3UbA8kb4p3EuLYAnQ=";
  version = "0-unstable-2025-01-20";
  branch = "staging-next";
}
