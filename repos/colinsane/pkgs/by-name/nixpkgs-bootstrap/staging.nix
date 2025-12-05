{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "744d65657ba73a2ff3e24d88010817c23ea9a56e";
  sha256 = "sha256-1Mi2uzisDbNpholGseVgfkF9l4YbtOzukIkJegsTgnM=";
  version = "unstable-2025-12-05";
  branch = "staging";
}
