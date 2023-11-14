{ lib, stdenv, fetchFromGitHub, cmake
, enableShared ? !stdenv.hostPlatform.isStatic }:

stdenv.mkDerivation rec {
  pname = "sleef";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "shibatch";
    repo = "sleef";
    rev = "69cfa7130f3f2bda838633071b1c63aa7d56f940";
    sha256 = "sha256-3Ms/dEk4FfG4+P94y/IySW6aEca18CMKcnw1xm6PhVc=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "_DENABLE_LTO=ON"
    "-DBUILD_SHARED_LIBS=${if enableShared then "ON" else "OFF"}"
    "-DCMAKE_C_FLAGS_RELEASE=${if stdenv.hostPlatform.isx86_64 then "-march=x86-64-v3" else ""}"
  ];

  meta = with lib; {
    description = "SIMD Library for Evaluating Elementary Functions";
    homepage = "https://sleef.org";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}

