{ lib
, stdenv
, fetchFromGitHub
, cmake
, buildShared ? !stdenv.hostPlatform.isStatic
}:

stdenv.mkDerivation rec {
  pname = "perf-cpp";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "foolnotion";
    repo = "perf-cpp";
    rev = "748c2bd6f60e392f74e2060d207c72cb77278771";
    hash = "sha256-n7+bjKRWRhxn+Ev560uUqrgyETXMm35boNV2UwaBd70=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DCMAKE_INSTALL_LIBDIR=lib" ] ++ lib.optional buildShared "-DBUILD_SHARED_LIBS=ON";

  meta = with lib; {
    description = "C++ library to make performance analysis more intuitive and focused";
    homepage = "https://github.com/jmuehlig/perf-cpp";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
