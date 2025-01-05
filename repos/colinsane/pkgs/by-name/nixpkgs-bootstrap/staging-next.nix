{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "e55147c3741f5f8b056b421a5d4dca878fae2f29";
  sha256 = "sha256-vq/o6p9yC8P/hqASbUo4nYAZtTSmT5hgS3O+O/phit0=";
  version = "0-unstable-2025-01-05";
  branch = "staging-next";
}
