{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "c9e934a620ad08be0c9872a268ac4f09153c62cf";
  sha256 = "sha256-5Gw93L9v7gK+KbwhjOcn1pvsVvyNEnsBUqbO2tHU+dE=";
  version = "0-unstable-2024-12-16";
  branch = "staging-next";
}
