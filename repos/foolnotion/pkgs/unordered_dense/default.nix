{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "unordered_dense";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "martinus";
    repo = "unordered_dense";
    rev = "v${version}";
    sha256 = "sha256-w5ACS87BQgfZEpweMLr0SGvEnSKPcOHiNCsCHqynrd8=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A fast & densely stored hashmap and hashset based on robin-hood backward shift deletion.";
    homepage = "https://github.com/martinus/unordered_dense";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
