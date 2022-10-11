{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "lunasvg";
  version = "2.3.4";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "lunasvg";
    rev = "v${version}";
    sha256 = "sha256-gXTAHM4I+ybmLMUOBtMm0A3gPjZUetJk2LrAoVlWy18=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = lib.optionals (!stdenv.hostPlatform.isStatic)
    [ "-DBUILD_SHARED_LIBS:BOOL=ON" ];

  meta = with lib; {
    description =
      "Standalone C++ library to create, animate, manipulate and render SVG files";
    homepage = "https://github.com/sammycage/lunasvg";

    license = licenses.mit;
    platforms = platforms.linux;
  };
}
