{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "xad";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "auto-differentiation";
    repo = "xad";
    rev = "v${version}";
    sha256 = "sha256-fF/UvW69eeZjTaYbA3KxXQTIKSZ+2mt+DptetaJLKHo=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DXAD_ENABLE_TESTS=OFF"
    "-DXAD_POSITION_INDEPENDENT_CODE=ON"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
  ];

  meta = with lib; {
    description = "C++ library for automatic differentiation";
    homepage = "https://github.com/auto-differentiation/XAD";
    license = licenses.agpl3;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
