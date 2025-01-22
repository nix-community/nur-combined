{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "61e08f26c001088a03f4cdb66b6f13be1d32e32a";
  sha256 = "sha256-oqUsEe0gOaUPye4GVHSTFzXFJ9nJKXAukGJPZX9Sulk=";
  version = "0-unstable-2025-01-22";
  branch = "staging-next";
}
