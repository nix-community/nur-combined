{ lib, stdenv, fetchFromGitHub
, withOneAPI ? false
, procps
, glibc
, intel-oneapi
, gcc
, cmake
}:
stdenv.mkDerivation rec {
  version = "3.6.01";
  pname = "kokkos";

  src = fetchFromGitHub {
    owner = "kokkos";
    repo = "kokkos";
    rev = version;
    sha256 = "0msqvcl4g6nrik6cgjha21ajbq2qv9h7y7g1dq64acqmwfcyh3ih";
  };

  nativeBuildInputs = [ procps glibc cmake ];

  enableParallelBuilding = true;

  buildInputs = [ gcc ]
    ++ (lib.optionals withOneAPI [ intel-oneapi ]);

  preConfigure = ''
    COMPILER=${if withOneAPI then "oneapi" else "cc"}
    if [ "$COMPILER" = "oneapi" ]
    then 
      source ${intel-oneapi}/setvars.sh
      export GCCROOT=${gcc}
      export GXXROOT=${gcc}
      export CC=icc
      export CXX=icpc
      export GXX_INCLUDE=${glibc.dev}/include
      export CXXFLAGS="-isystem ${stdenv.cc.cc}/include/c++/${stdenv.cc.version} -isystem ${stdenv.cc.cc}/include/c++/${stdenv.cc.version}/x86_64-unknown-linux-gnu"
      export CFLAGS="-isystem ${stdenv.cc.cc}/include/c++/${stdenv.cc.version} -isystem ${stdenv.cc.cc}/include/c++/${stdenv.cc.version}/x86_64-unknown-linux-gnu"
    fi
  '';

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=$out"
    "-DKokkos_ENABLE_LIBDL=OFF"
    "-DKokkos_CXX_STANDARD=17"
  ];

}
