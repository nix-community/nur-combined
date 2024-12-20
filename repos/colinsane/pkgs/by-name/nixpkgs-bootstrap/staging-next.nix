{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "59ce48c98b4794da1a7bc3971563b82af70f3afd";
  sha256 = "sha256-saqfJEUgnrznctnLl7iGFD++oPgaWC4wum+bf3rfvUM=";
  version = "0-unstable-2024-12-20";
  branch = "staging-next";
}
