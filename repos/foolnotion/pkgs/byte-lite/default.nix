{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "byte-lite";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "martinmoene";
    repo = "byte-lite";
    rev = "v${version}";
    sha256 = "sha256-8FBP1XQBzQiwGavrgi+KpDPOkL0hfjtL9wxHT4y2yUE=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A single-file header-only C++17-like byte type for C++98, C++11 and later";
    homepage = "https://github.com/martinmoene/span-lite";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
