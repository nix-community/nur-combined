{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "a24829159b90c30947fb093a8bed1cf19dbf6f7c";
  sha256 = "sha256-+wYJS1jqXF9SaH9t53CSy34zttQKSeUPYuDHzLRDITE=";
  version = "0-unstable-2025-01-23";
  branch = "staging-next";
}
