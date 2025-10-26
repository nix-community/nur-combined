{ lib
, stdenv
, fetchFromGitHub
, cmake
, buildShared ? !stdenv.hostPlatform.isStatic
}:

stdenv.mkDerivation rec {
  pname = "perf-cpp";
  version = "0.12.3";

  src = fetchFromGitHub {
    owner = "jmuehlig";
    repo = "perf-cpp";
    rev = "v${version}";
    hash = "sha256-buKb+gh1q1wdNpm7azmf/MPDZkY9tEa5ptdxRj9B958=";
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
