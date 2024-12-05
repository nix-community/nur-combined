{ lib
, stdenv
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation rec {
  pname = "dynamic_bitset";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "pinam45";
    repo = "dynamic_bitset";
    rev = "v${version}";
    sha256 = "sha256-+1OFvfXyYQ07VVLUol6jhQoB0lSkODy9fLpW/1FWpPo=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DDYNAMICBITSET_INSTALL=ON"
    "-DDYNAMICBITSET_BUILD_EXAMPLE=OFF"
    "-DDYNAMICBITSET_BUILD_TESTS=OFF"
    "-DDYNAMICBITSET_FORMAT_TARGET=OFF"
    "-DDYNAMICBITSET_BUILD_DOCS=OFF"
    "-DDYNAMICBITSET_USE_STD_BITOPS=ON"
    "-DDYNAMICBITSET_USE_COMPILER_BUILTIN=ON"
  ];

  meta = with lib; {
    description = "C++17/20 header-only dynamic bitset";
    homepage = "https://pinam45.github.io/dynamic_bitset/";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
