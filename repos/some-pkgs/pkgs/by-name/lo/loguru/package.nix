{ lib
, stdenv
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation rec {
  pname = "loguru";
  version = "unstable-2023-09-24";

  src = fetchFromGitHub {
    owner = "emilk";
    repo = "loguru";
    rev = "master";
    hash = "sha256-NpMKyjCC06bC5B3xqgDr2NgA9RsPEeiWr9GbHrHHzZ8=";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = with lib; {
    description = "A lightweight C++ logging library";
    homepage = "https://github.com/emilk/loguru";
    license = licenses.unlicense;
    maintainers = with maintainers; [ SomeoneSerge ];
    mainProgram = "loguru";
    platforms = platforms.all;
  };
}
