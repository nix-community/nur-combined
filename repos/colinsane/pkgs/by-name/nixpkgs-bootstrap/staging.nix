{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "c12baeb6ca57d5b195de97db0b2c73c8580f5091";
  sha256 = "sha256-ZakBk2ouWA0qW3aoC2H94fTDGFPN39rMe8a8eNhKN0o=";
  version = "0-unstable-2025-01-18";
  branch = "staging";
}
