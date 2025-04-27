{ stdenv, fetchFromGitHub, ... }:
let
  cosmo_version = "3.9.7";
in
stdenv.mkDerivation {
  pname = "ape";
  version = "1.10";

  src = fetchFromGitHub {
    owner = "jart";
    repo = "cosmopolitan";
    rev = cosmo_version;
    hash = ;
  };
}
