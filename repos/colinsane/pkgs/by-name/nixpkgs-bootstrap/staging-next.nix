{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "e5cd6d41e9cfcf93455c7c80804d75a7c2ed3931";
  sha256 = "sha256-N+QMX67plJEHZjWywh1DH7bK73NYaZsu3+L2IzZtesk=";
  version = "0-unstable-2025-01-26";
  branch = "staging-next";
}
