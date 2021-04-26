{ stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  boost,
  eigen,
  zlib }:

stdenv.mkDerivation rec {
  pname = "iqtree2";
  version = "2.1.3";

  src = fetchFromGitHub {
    owner = "iqtree";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-piVrbyjjK4+ObDfoxN2hxiYRywB+U0sBdn6L+ygz5lk=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DIQTREE_FLAGS=omp"
  ];

  buildInputs = [ boost eigen zlib ];

  meta = with lib; {
    description = "Efficient and versatile phylogenomic software by maximum likelihood";
    license = licenses.gpl2Only;
    homepage = "http://www.iqtree.org/";
    maintainers = with maintainers; [ dschrempf ];
    platforms = platforms.all;
  };
}
