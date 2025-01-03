{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "086d2350e4ce3fa2ac940a6b969bab646dd3c334";
  sha256 = "sha256-zgi/ZyM31uT1WTXpUHkgS/COo/HXj2cm97iLmgMyHzA=";
  version = "0-unstable-2025-01-02";
  branch = "staging-next";
}
