{ stdenv, lib, buildGoPackage, fetchFromGitHub }:
let
  go-xlsx = buildGoPackage rec {
  name = "go-xlsx-${version}";
  version = "46e6e472d";

  goPackagePath = "github.com/tealeg/xlsx";
  src = fetchFromGitHub {
    rev = version;
    owner = "tealeg";
    repo = "xlsx";
    sha256 = "1vls05asms7azhyszbqpgdby9l45jpgisbzzmbrzi30n6cvs89zg";
  };
};
in
(buildGoPackage rec {
  name = "git-xlsx-textconv-${version}";
  version = "70685e7f8";


  goPackagePath = "github.com/tokuhirom/git-xlsx-textconv";

  src = fetchFromGitHub {
    rev = version;
    owner = "tokuhirom";
    repo = "git-xlsx-textconv";
    sha256 = "055f3caj1y8v7sc2pz9q0dfyi2ij77d499pby4sjfvm5kjy9msdi";
  };
  propagatedBuildInputs = [ go-xlsx ];
  #meta.broken = true;
})
