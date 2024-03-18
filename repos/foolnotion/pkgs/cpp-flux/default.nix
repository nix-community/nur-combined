{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "cpp-flux";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "tcbrindle";
    repo = "flux";
    rev = "b8047a547659d41e6c91f3a20c8acd42326de8ea";
    hash = "sha256-yfIxg0ex1lqtC9epUzKaIMRUebRyygEIrlZvo/yyg6k=";
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
