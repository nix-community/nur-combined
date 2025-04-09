{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "parallel-hashmap";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "greg7mdp";
    repo = "parallel-hashmap";
    rev = "v${version}";
    sha256 = "sha256-JiDhEpAQyyPXGkY9DYLvJ2XW1Bp3Ex1iMtbzNdra95g=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DPHMAP_INSTALL=ON" "-DPHMAP_BUILD_TESTS=OFF" "-DPHMAP_BUILD_EXAMPLES=OFF" ];

  postInstall = ''
    substituteInPlace phmapTargets.cmake --replace "/build/source" "$out/include"
    mkdir -p $out/lib/cmake/phmap
    install -m 644 phmapTargets.cmake $out/lib/cmake/phmap/
    echo "include(\"''\\$''\{CMAKE_CURRENT_LIST_DIR}/phmapTargets.cmake\"''\)" > $out/lib/cmake/phmap/phmapConfig.cmake
  '';

  meta = with lib; {
    description = "Very efficient, memory friendly, concurrent, drop-in replacement for std::unordered_map, std::unordered_set, std::map and std::set";
    homepage = "https://github.com/greg7mdp/parallel-hashmap";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
