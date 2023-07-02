{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "lunasvg";
  version = "2.3.8";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "lunasvg";
    rev = "v${version}";
    sha256 = "sha256-Ap6QgCANpuamvJ3x6JT0uIGePFlQfECJF6IF219yk+Q=";
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
