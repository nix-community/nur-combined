{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "small_vector";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "gharveymn";
    repo = "small_vector";
    rev = "v${version}";
    sha256 = "sha256-ln/dw96+AnsH3gOpn8k8yD+kPqU+Z3Zt/IQTFvCrB94=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DGCH_SMALL_VECTOR_ENABLE_TESTS=OFF" ];

  meta = with lib; {
    description = "A C++ vector container implementation with a small buffer optimization";
    homepage = "https://github.com/gharveymn/small_vector";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
