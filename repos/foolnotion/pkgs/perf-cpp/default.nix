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
    rev = "d08b7705255f32af063d846050473a003f7bd126";
    hash = "sha256-mbyvneFFb8TxYON2MTWC8QYhlZabxIW31zEeE1dBTw0=";
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
