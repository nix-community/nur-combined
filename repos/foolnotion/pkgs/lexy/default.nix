{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "lexy";
  version = "2025.05.0";

  src = fetchFromGitHub {
    owner = "foonathan";
    repo = "lexy";
    rev = "v${version}";
    sha256 = "sha256-ONoMGos5Xo2JqvXwLmq6B7XH1eG25FVkSbgYKvr5QpI=";
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
