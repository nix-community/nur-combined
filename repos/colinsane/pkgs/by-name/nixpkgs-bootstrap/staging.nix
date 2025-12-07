{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "2c29b957e1e09f82cbf165583151bcb6da16e712";
  sha256 = "sha256-5CSc7nKfadFRMRvAQI1AoawK+aKXne+tmCRNsEz+yLo=";
  version = "unstable-2025-12-06";
  branch = "staging";
}
