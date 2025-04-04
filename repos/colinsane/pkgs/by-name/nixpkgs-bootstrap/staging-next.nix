{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "7b881933073a68a6b76917b1b64c1b538547903d";
  sha256 = "sha256-iz1V93JWiX0t2xbJno0hhj3NawLJC4RP2c3Xx5zQ5QY=";
  version = "0-unstable-2025-04-03";
  branch = "staging-next";
}
