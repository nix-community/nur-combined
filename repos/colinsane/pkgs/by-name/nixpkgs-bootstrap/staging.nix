{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "b4d0fe2499f4f31c5a71e704488ad43d6bbe82f1";
  sha256 = "sha256-59ZaYqpMFzoYuJyhQitDafbHzLknkoIG6gi1O6CaN6U=";
  version = "0-unstable-2025-03-24";
  branch = "staging";
}
