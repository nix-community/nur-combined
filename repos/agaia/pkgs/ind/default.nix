{ lib, fetchFromGitHub }:
let 
  src = fetchFromGitHub {
    owner = "adam-gaia";
    repo = "ind";
    rev = "47b0f3ca1c06c055b3957c049672edb84fabfcf7";
    sha256 = "05lnv3xzijqq2h95jj2c7bla6zxmr88ybr6sszxbscksvdrq158g";
  };
in
  import "${src}/default.nix"

