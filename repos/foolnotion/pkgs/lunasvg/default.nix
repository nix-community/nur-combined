{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "lunasvg";
  version = "2.3.9";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "lunasvg";
    rev = "v${version}";
    hash = "sha256-A/ONhRQ+NVw3tVlKq8HEz/wMSH+xT5WJO3w6wdH/2jc=";
  };

  nativeBuildInputs = [ cmake ];
  cmakeFlags = [ "-DLUNASVG_BUILD_EXAMPLES=0" ];

  patches = [ ./fix-cmake.patch ];

  meta = with lib; {
    description = "SVG rendering library in C++";
    homepage = "https://github.com/sammycage/lunasvg";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
