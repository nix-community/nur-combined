{ stdenv, lib, fetchFromGitHub, cmake }:
stdenv.mkDerivation rec {
  pname = "lunasvg";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "lunasvg";
    rev = "v${version}";
    sha256 = "0s9fwf3gf03jqp12lyvnh0ddq7qx8arvikl3pqh4cl3w372fsw8l";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SHARED_LIBS=TRUE"
  ];

  meta = with lib; {
    description = "A standalone c++ library to create, animate, manipulate and render SVG files";
    homepage = "https://github.com/sammycage/lunasvg";

    license = licenses.mit;
    maintainers = [  ];
    platforms = platforms.linux;
  };
}
