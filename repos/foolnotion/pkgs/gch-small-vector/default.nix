{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "small_vector";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "gharveymn";
    repo = "small_vector";
    rev = "3c69db910d973874f4468c6fb445e6a30eec906c";
    sha256 = "sha256-xvPrh5f2G4qGoFrnMiCk3T87Vk1CuElTY4gdzkKHG5E=";
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
