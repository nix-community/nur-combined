{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "lexy";
  version = "2024.09.12";

  src = fetchFromGitHub {
    owner = "foonathan";
    repo = "lexy";
    rev = "77ba5fa5a62f16b3ab5440c6d6ef42a7cdd176bb";
    sha256 = "sha256-BQUQAss0NLSsNYcCIXzN3355BZb789qguwlaazZcC4U=";
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
