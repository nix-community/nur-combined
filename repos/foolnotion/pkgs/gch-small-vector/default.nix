{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "small_vector";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "gharveymn";
    repo = "small_vector";
    rev = "d98388b21b73be55e8c36ee18809e19a6fa82d34";
    sha256 = "sha256-iotI9Ql+D6hNMBGPSbqJs5qJGSLCn/NVMRWQX8F++wk=";
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
