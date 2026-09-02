{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "4639cf1a479c09a85dea00c5e3a31a79e2ea9be4";
  sha256 = "sha256-Ewg4Rh+B/GuIU91ezy+7wtIy6OHBfu1MDCAUeOI0dAQ=";
  version = "unstable-2026-09-01";
  branch = "staging-next";
}
