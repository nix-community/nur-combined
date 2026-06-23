{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "dbf9120a626230780514832b0b7a2ca1c688de76";
  sha256 = "sha256-3azNR96Nm8OlshEIlukg/nwKMaJQRUGvWBaKI8tt4jU=";
  version = "unstable-2026-06-23";
  branch = "staging-next";
}
