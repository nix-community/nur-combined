{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "eecfb28d1809b9e04171437f48f95a259d00c828";
  sha256 = "sha256-0mEytm6qzck8xPXbkAa5RYHMKW1RI7C2zsTOWlXHXMY=";
  version = "unstable-2025-12-02";
  branch = "staging-next";
}
