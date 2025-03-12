{ lib, stdenv, fetchFromGitHub, boost, cmake, eigen }:

stdenv.mkDerivation rec {
  version = "2.1.2"; 
  name = "iqtree-${version}";

  src = fetchFromGitHub {
    owner = "iqtree";
    repo = "iqtree2";
    rev = "v${version}";
    sha256 = "1bfa0kkb6vfcpa0vvx5cv1qinq3dachpzxbs5wqvp79ksyypbhyj";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost eigen ];

  meta = {
     description = "efficient and versatile phylogenomic software by maximum likelihood";
     homepage = http://www.iqtree.org;
     license = with lib.licenses; [ gpl2 ];
     maintainers = with lib.maintainers; [ bzizou ];
  };
}

