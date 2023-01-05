{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "lexy";
  version = "2022.12.1";

  src = fetchFromGitHub {
    owner = "foonathan";
    repo = "lexy";
    rev = "v${version}";
    sha256 = "sha256-tLLxJpXMPxlmjKTqClC+8AGpap/Nrd7TtaycMLNaLxQ=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DLEXY_BUILD_TESTS=OFF"
    "-DLEXY_BUILD_EXAMPLES=OFF"
    "-DLEXY_ENABLE_INSTALL=ON"
  ];

  meta = with lib; {
    description = "A parser combinator library for C++17 and onwards.";
    homepage = "https://github.com/foonathan/lexy";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
