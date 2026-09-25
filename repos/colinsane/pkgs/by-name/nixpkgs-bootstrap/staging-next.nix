{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "f8b3e0beb82b4e105fafd0b85138c083ad593a4b";
  sha256 = "sha256-blZyGdSn0bP+OZCtPE1GXzEGGpNxKtP4ZeMYDARjKZw=";
  version = "unstable-2026-09-24";
  branch = "staging-next";
}
