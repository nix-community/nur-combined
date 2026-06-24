{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "e65336901fefb02c7ce795505a81633fa0242fc2";
  sha256 = "sha256-pycRVtGSTBBFh8+BRkGpK9hjVClH9Tgw7VhOutbEaC4=";
  version = "unstable-2026-06-24";
  branch = "staging-next";
}
