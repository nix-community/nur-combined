{ lib, stdenv, cmake, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "trng";
  version = "4.25";

  src = fetchFromGitHub {
    owner = "rabauke";
    repo = "trng4";
    rev = "efdb3cfdb589a1f34ce4dfde85a8a068451018e3";
    hash = "sha256-luY7eqm/dOXTWzXdY6fl248qUUo90y48xx2+m7tq6+Q=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TESTING=0"
    "-DBUILD_SHARED_LIBS=0"
  ];


  meta = with lib; {
    description = "Modern C++ pseudo random number generator library";
    homepage = "https://github.com/rabauke/trng4";
    license = licenses.bsd3;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
