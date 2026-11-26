{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "744917e77c88e60acecbf812dc18fb2e03054877";
  sha256 = "sha256-6Zk+dNtkmlcUalmO2OLIyVlf6e+QlpV503nEepMunOo=";
  version = "unstable-2026-11-22";
  branch = "staging";
}
