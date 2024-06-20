{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "cppsort";
  version = "1.16.0";

  src = fetchFromGitHub {
    owner = "Morwenn";
    repo = "cpp-sort";
    rev = "${version}";
    hash = "sha256-NUza//JWix3N5IRe73bw4qrtV3sU/LZF8FgNUhhLN0k=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DCPPSORT_BUILD_TESTING=OFF"
    "-DCPPSORT_BUILD_EXAMPLES=OFF"
  ];

  meta = with lib; {
    description = "Generic header-only C++14 sorting library.";
    homepage = "https://github.com/Morwenn/cpp-sort";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
