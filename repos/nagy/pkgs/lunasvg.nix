{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "lunasvg";
  version = "2.3.2";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "lunasvg";
    rev = "v${version}";
    sha256 = "sha256-SCui/R/7cznAqfkqDFzmm4Atsd6r4PTIm0bJyx/L3t4=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" "-DBUILD_SHARED_LIBS=TRUE" ];

  meta = with lib; {
    description =
      "Standalone C++ library to create, animate, manipulate and render SVG files";
    homepage = "https://github.com/sammycage/lunasvg";

    license = licenses.mit;
    platforms = platforms.linux;
  };
}
