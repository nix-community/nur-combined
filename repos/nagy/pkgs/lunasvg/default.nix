{ stdenv, lib, fetchFromGitHub, cmake }:
stdenv.mkDerivation rec {
  pname = "lunasvg";
  version = "2.1.5";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "lunasvg";
    rev = "v${version}";
    sha256 = "1h823ya10rl3j6b2rg0mwn60b760pj3qdd42za4s8mpv8dg2ridm";
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
