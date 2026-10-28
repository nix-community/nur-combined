{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "99ece1895d6a5b05a178b29f5e5acf09b5e288f6";
  sha256 = "sha256-Uz2P2ovhnwLqauDYqBDUGGnUYF9VXbNyanX2iqoZFE8=";
  version = "unstable-2026-10-26";
  branch = "staging-next";
}
