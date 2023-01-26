{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "small_vector";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "gharveymn";
    repo = "small_vector";
    rev = "8c7dfde9edd65f2822799a1d2d1841a9c8a411f4";
    sha256 = "sha256-9gpX5x+EeRgsK1g+MqPfURZPpJxlTWxqbRM+TmeFWsk=";
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
