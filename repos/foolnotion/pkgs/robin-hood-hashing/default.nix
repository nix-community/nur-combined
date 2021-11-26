{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "robin-hood-hashing";
  version = "3.11.3";

  src = fetchFromGitHub {
    owner = "martinus";
    repo = "robin-hood-hashing";
    rev = "${version}";
    sha256 = "sha256-9IamneqbZwQA63U2GyGTVWIHvwTtT+/oqQgaOCWno74=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DRH_STANDALONE_PROJECT=OFF" ];

  meta = with lib; {
    description = "Platform independent replacement for std::unordered_map / std::unordered_set which is both faster and more memory efficient for real-world use cases.";
    homepage = "https://github.com/martinus/robin-hood-hashing";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
