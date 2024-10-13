{ lib, stdenv, fetchFromGitHub, cmake, plutovg }:
stdenv.mkDerivation rec {
  pname = "lunasvg";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "lunasvg";
    rev = "v${version}";
    hash = "sha256-8LynQ0dG7gFydbFI6ET5VeKqh4/NT8jXKBBgNwXCRQo=";
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
