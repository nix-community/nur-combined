{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "e4f77a55ee4b4e9a54d06ccb177ac7974eb573b7";
  sha256 = "sha256-WDgeFe+t0ouffOjSd3TTVWWa9+d+D4mdr8gO5RKlA5Y=";
  version = "unstable-2026-11-19";
  branch = "staging";
}
