{ lib
, stdenv
, fetchFromGitHub
, cmake
, buildShared ? !stdenv.hostPlatform.isStatic
}:

stdenv.mkDerivation rec {
  pname = "perf-cpp";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "jmuehlig";
    repo = "perf-cpp";
    rev = "v${version}";
    hash = "sha256-uOI0nYBTLHhGjUEgY6MZRZIEBTdF7SOCYBMoEwaNG9E=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ ] ++ lib.optional buildShared "-DBUILD_SHARED_LIBS=ON";

  meta = with lib; {
    description = "C++ library to make performance analysis more intuitive and focused";
    homepage = "https://github.com/jmuehlig/perf-cpp";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
