{ callPackage, fetchFromGitHub }:

callPackage ./generic.nix (rec {
  version = "1.5";
  src = fetchFromGitHub {
    owner = "yurrriq";
    repo = "nixops";
    rev = "3c5efba";
    sha256 = "0qsfdmijml6vqwbs5m38dc33j08kxhs3jw6vg747abaskjgjaz7x";
  };
})
