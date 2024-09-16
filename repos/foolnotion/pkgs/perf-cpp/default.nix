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
    rev = "59c22842571c1c17a5df9c7e86167e6ce5b0550f";
    hash = "sha256-Miv9vLymQuTmJsqDiPaAyhNlto5wOdJ83ZlkogXYoek=";
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
