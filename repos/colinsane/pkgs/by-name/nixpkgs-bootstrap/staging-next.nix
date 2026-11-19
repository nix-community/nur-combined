{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "a946dc69845d01dd47b4c311e796e90c6961c082";
  sha256 = "sha256-QOlxxRf07d6V/rdAsbM8orrjaIm9YPnLc8t6qNbL6bk=";
  version = "unstable-2026-11-19";
  branch = "staging-next";
}
