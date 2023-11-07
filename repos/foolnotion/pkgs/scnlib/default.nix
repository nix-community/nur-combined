{ lib, stdenv, fetchFromGitHub, cmake
, enableShared ? !stdenv.hostPlatform.isStatic }:

stdenv.mkDerivation rec {
  pname = "scnlib";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "eliaskosunen";
    repo = "scnlib";
    rev = "v${version}";
    sha256 = "sha256-IkPdljh3mNXuOKP1lQlU1SS9XHvS4agGBtrmrF2hFKY=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DSCN_TESTS=OFF"
    "-DSCN_BENCHMARKS=OFF"
    "-DSCN_EXAMPLES=OFF"
    "-DBUILD_SHARED_LIBS=${if enableShared then "ON" else "OFF"}"
  ];

  meta = with lib; {
    description = "Modern C++ library for replacing scanf and std::istream. .";
    homepage = "https://scnlib.readthedocs.io/";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
