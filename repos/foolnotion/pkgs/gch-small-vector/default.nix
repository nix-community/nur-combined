{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "small_vector";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "gharveymn";
    repo = "small_vector";
    rev = "6b054e7a3641fb41cc68387befddfc47c316bb3f";
    sha256 = "sha256-ftv1X30uFtgJ3lh2OswkvCdmUQWxbwMyJyotJC4qazg=";
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
