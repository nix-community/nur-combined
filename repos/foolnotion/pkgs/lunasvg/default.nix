{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "lunasvg";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "lunasvg";
    rev = "v${version}";
    hash = "sha256-U/ohYe5j/c7bGvEFkEHZPggdzt6vu9ThnzVgECG8AWk=";
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
