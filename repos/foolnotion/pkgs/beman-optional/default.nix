{ lib, stdenv, fetchFromGitHub, cmake, ninja }:

stdenv.mkDerivation rec {
  pname = "optional";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "bemanproject";
    repo = "optional";
    rev = "dc61636e06e43f05dddd4b7689a548350dee5ca8";
    hash = "sha256-gGbEYS+WAb/vfQImCojHH8B1YvjRyj67zsrvfqI3Cpc=";
  };

  nativeBuildInputs = [ cmake ninja ];

  cmakeFlags = [
    "-DOPTIONAL_ENABLE_TESTING=OFF"
    "-DCMAKE_CXX_STANDARD=20"
  ];

  meta = with lib; {
    description = "C++26 Extensions for std::optional";
    homepage = "https://github.com/bemanproject/optional";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
