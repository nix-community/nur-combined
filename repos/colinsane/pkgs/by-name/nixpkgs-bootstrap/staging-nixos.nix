{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "60cf12cd8ba3aa5c251c4d5c91aa8acdd8c0f3c3";
  sha256 = "sha256-mxD448YKcXRbo7oU8f88wk5A3+cPJGmjFZG5Bz/P80I=";
  version = "unstable-2026-09-28";
  branch = "staging-nixos";
}
