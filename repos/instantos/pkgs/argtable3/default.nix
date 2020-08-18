{ stdenv 
, lib
, fetchFromGitHub
, cmake
}:
stdenv.mkDerivation rec {
  pname = "argtable";
  version = "3.1.5.1c1bb23";

  src = fetchFromGitHub {
    owner = "argtable";
    repo = "argtable3";
    rev = "v${version}";
    sha256 = "1hw82br6lwkmagqrsq273k8yhb6qgyqqrfld1ns54brf3fgsdgmh";
  };

  postPatch = ''
    patchShebangs tools/build
  '';

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DARGTABLE3_ENABLE_TESTS=ON"
  ];

  # buildPhase = ''
  #   gcc -shared -o libargtable3.so -fPIC argtable3.c

  #   pushd tests
  #   make
  #   popd
  #   pushd doc
  #   doxygen
  #   popd
  #   make html
  # '';


  meta = with stdenv.lib; {
    homepage = "https://www.argtable.org/";
    description = "A Cross-Platform, Single-File, ANSI C Command-Line Parsing Library";
    license = licenses.bsd3;
    maintainers = with maintainers; [ artuuge ];
  };
}
