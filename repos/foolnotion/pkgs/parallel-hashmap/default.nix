{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "parallel-hashmap";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "greg7mdp";
    repo = "parallel-hashmap";
    rev = "v${version}";
    sha256 = "sha256-QDRy6YPoE34VpldN66V4mcF3PqK43RSlXThm+SzxRQ4=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DPHMAP_INSTALL=ON" "-DPHMAP_BUILD_TESTS=OFF" "-DPHMAP_BUILD_EXAMPLES=OFF" ];

  meta = with lib; {
    description = "Very efficient, memory friendly, concurrent, drop-in replacement for std::unordered_map, std::unordered_set, std::map and std::set";
    homepage = "https://github.com/greg7mdp/parallel-hashmap";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
