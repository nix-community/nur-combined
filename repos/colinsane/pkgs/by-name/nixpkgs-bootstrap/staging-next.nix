{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "8851035b3a3c8badafd42ebb5d5c5a1cdbf37767";
  sha256 = "sha256-VLJL0eQmJNhpx8QWkDTI33uv3GrwxTY9MHQZ2hXEtwc=";
  version = "unstable-2026-06-14";
  branch = "staging-next";
}
