{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "trng";
  version = "4.24";

  src = fetchFromGitHub {
    owner = "rabauke";
    repo = "trng4";
    rev = "v${version}";
    sha256 = "sha256-yqiUe47ydOWB5QFaHjGEh1QJph+2LKqV75fM9BQwtxA=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Modern C++ pseudo random number generator library";
    homepage = "https://github.com/rabauke/trng4";
    license = licenses.bsd3;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
