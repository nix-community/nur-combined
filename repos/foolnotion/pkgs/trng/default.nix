{ lib
, stdenv
, cmake
, fetchFromGitHub
, enableStatic ? stdenv.hostPlatform.isStatic
}:

stdenv.mkDerivation rec {
  pname = "trng";
  version = "4.27";

  src = fetchFromGitHub {
    owner = "rabauke";
    repo = "trng4";
    rev = "v${version}";
    hash = "sha256-AdefU9a9BG6dw6tDHpQ3UNzuGryz+hx3HepeNDW9ky0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TESTING=OFF"
    "-DBUILD_SHARED_LIBS=${if enableStatic then "OFF" else "ON"}"
  ];


  meta = with lib; {
    description = "Modern C++ pseudo random number generator library";
    homepage = "https://github.com/rabauke/trng4";
    license = licenses.bsd3;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
