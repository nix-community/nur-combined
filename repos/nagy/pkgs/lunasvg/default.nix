{ stdenv, lib, fetchFromGitHub, cmake }:
stdenv.mkDerivation rec {
  pname = "lunasvg";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "lunasvg";
    rev = "v${version}";
    sha256 = "0sw41hvs95f82gdxjp5wiaj1r55wlikrmvw2mp6kwb0m3jvrk259";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SHARED_LIBS=TRUE"
  ];

  meta = with lib; {
    description = "Standalone C++ library to create, animate, manipulate and render SVG files";
    homepage = "https://github.com/sammycage/lunasvg";

    license = licenses.mit;
    maintainers = [  ];
    platforms = platforms.linux;
  };
}
