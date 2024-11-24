{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "975e7e7c20bee89f9cf14a0b26401cb93fe36381";
  sha256 = "sha256-IeiNrCafLCGjz2+2SY8sjhdyljSu62YCKmhvzwOYUuk=";
  version = "0-unstable-2024-11-23";
  branch = "master";
}
