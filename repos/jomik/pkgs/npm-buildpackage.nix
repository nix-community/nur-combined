{ callPackage, fetchFromGitHub}:

callPackage (fetchFromGitHub {
  owner = "serokell";
  repo = "nix-npm-buildpackage";
  rev = "fc42625d30aadb3cefef19184baeba6524631b70";
  sha256 = "15dq93x460wzyw1irw3i50rrpi16zilgv3r4bswywgfy02rnx3r8";
}) {}
