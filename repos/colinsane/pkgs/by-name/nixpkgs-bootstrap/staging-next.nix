{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "63300a19421298a1727f6dcf4a3ae3faaa5cd47c";
  sha256 = "sha256-GnlvDKZOJjAUdci8qhCJPIsd6RsSARPSLOfZqXWuycI=";
  version = "0-unstable-2024-12-01";
  branch = "staging-next";
}
