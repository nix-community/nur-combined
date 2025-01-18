{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "0a5e75bb2ec4444475449ef0b4f1fa6a5ea64b58";
  sha256 = "sha256-ZoU0fJrLIG5rgLrx3qRIgyv67SJ3r2nNRIBkYwKY28w=";
  version = "0-unstable-2025-01-18";
  branch = "staging-next";
}
