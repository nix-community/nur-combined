{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "cpp-flux";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "tcbrindle";
    repo = "flux";
    rev = "v${version}";
    hash = "sha256-gmWDCPlvJOoCz3drVClC1zuJqIi5qclMZ9ADieBNtZ8=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DFLUX_BUILD_EXAMPLES=OFF"
    "-DFLUX_BUILD_TESTS=OFF"
  ];

  meta = with lib; {
    description = "A C++20 library for sequence-orientated programming";
    homepage = "https://github.com/tcbrindle/flux";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
