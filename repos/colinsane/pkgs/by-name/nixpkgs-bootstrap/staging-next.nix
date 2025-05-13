{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "86051b5e95d26b6b22cf13490da503d87af4a13b";
  sha256 = "sha256-ER+GWLNW67AH67vXooI7AXzakzEVvtDejBnN5eoMCFM=";
  version = "unstable-2025-05-13";
  branch = "staging-next";
}
