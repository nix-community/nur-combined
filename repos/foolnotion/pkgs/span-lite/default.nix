{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "span-lite";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "martinmoene";
    repo = "span-lite";
    rev = "v${version}";
    sha256 = "sha256-BYRSdGzIvrOjPXxeabMj4tPFmQ0wfq7y+zJf6BD/bTw=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A single-file header-only version of a C++20-like span for C++98, C++11 and later.";
    homepage = "https://github.com/martinmoene/span-lite";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
