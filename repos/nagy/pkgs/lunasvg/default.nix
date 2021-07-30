{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "lunasvg";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "lunasvg";
    rev = "v${version}";
    sha256 = "05y50f7lgbcx64dd430khwrck13mjwskkijx8g7y7i77a95rrqhf";
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
