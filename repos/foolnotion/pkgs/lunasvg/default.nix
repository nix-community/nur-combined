{ lib, stdenv, fetchFromGitHub, cmake, plutovg }:

stdenv.mkDerivation rec {
  pname = "lunasvg";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "lunasvg";
    rev = "v${version}";
    hash = "sha256-eSkYkxdV5L31cIJtH6cVfQU2nguA3BPCQXnIMnColek=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ plutovg ];
  cmakeFlags = [ "-DLUNASVG_BUILD_EXAMPLES=0" "-DUSE_SYSTEM_PLUTOVG=1" ];

  patches = [ ./lunasvg_pkgconfig.patch ];

  meta = with lib; {
    description = "SVG rendering library in C++";
    homepage = "https://github.com/sammycage/lunasvg";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
