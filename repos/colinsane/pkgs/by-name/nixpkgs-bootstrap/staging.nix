{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "0e5528db29fc7283f158eaf07640150b958dcb6e";
  sha256 = "sha256-Lwaa+VAhc4KnetU+xBydOBNQYYgnsj8OVRSzFedgOTM=";
  version = "unstable-2026-06-09";
  branch = "staging";
}
