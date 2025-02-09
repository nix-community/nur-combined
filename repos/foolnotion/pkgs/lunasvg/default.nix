{ lib, stdenv, fetchFromGitHub, cmake, plutovg }:
stdenv.mkDerivation rec {
  pname = "lunasvg";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "lunasvg";
    rev = "v${version}";
    hash = "sha256-9cw3flnQN366C9xbP2JTRsTQsFVJUVr5M25kDy6njcU=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ plutovg ];
  cmakeFlags = [ "-DLUNASVG_BUILD_EXAMPLES=0" ];

  meta = with lib; {
    description = "SVG rendering library in C++";
    homepage = "https://github.com/sammycage/lunasvg";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
