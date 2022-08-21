{ stdenv
, lib
, fetchFromGitHub
, cmake
, boost
, eigen
, zlib
}:

stdenv.mkDerivation rec {
  pname = "iqtree2";
  version = "2.2.0.5";

  src = fetchFromGitHub {
    owner = "iqtree";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-LqaHoGixHjLrjtrJlCDqh9UkrGUSAiK7STL/Yyc7cZQ=";
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
