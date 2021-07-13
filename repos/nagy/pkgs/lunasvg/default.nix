{ stdenv, lib, fetchFromGitHub, cmake }:
stdenv.mkDerivation rec {
  pname = "lunasvg";
  version = "2.1.4";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "lunasvg";
    rev = "v${version}";
    sha256 = "1ay7ap7r1qlfvgl5m7dav5x3siyqqyd06i029y3pvwrw0szqw742";
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
