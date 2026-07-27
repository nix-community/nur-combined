{ lib, callPackage, fetchFromGitHub, npm-buildpackage }:

let
  inherit (npm-buildpackage) buildYarnPackage;
in buildYarnPackage rec {
  src = fetchFromGitHub {
    owner = "screepers";
    repo = "screeps-multimeter";
    rev = "v1.8.0";
    sha256 = "0x73qlv63q0cyfka0gwrg2kg15ygqnk723qmcr9zrxffk9wx0gc3";
  };

  meta = {
    license = lib.licenses.mit;
  };
}
