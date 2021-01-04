{ stdenv, fetchFromGitHub, cmake }:
stdenv.mkDerivation rec {
  pname = "lunasvg";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "lunasvg";
    rev = "v${version}";
    sha256 = "13n46mrksmc3pdczdq8z8cap2v33zv00srkc5j81z0kw8abdjkbq";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SHARED_LIBS=TRUE"
  ];

  meta = {
    description = "A standalone c++ library to create, animate, manipulate and render SVG files";
    homepage = "https://github.com/sammycage/lunasvg";

    license = stdenv.lib.licenses.mit;
    maintainers = [  ];
    platforms = stdenv.lib.platforms.linux;
  };
}
