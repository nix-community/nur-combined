{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "7e5390675b9bb5dd797c50d9135e1acf91b30a3d";
  sha256 = "sha256-MqDGrKJ6WbwTnWw9halGndaBy1HT/PoT4Yr5XOgkLsk=";
  version = "unstable-2025-06-04";
  branch = "staging";
}
