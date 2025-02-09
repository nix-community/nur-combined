{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "plutovg";
  version = "0.0.12";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "plutovg";
    rev = "v${version}";
    hash = "sha256-ruwgZ+ZXXGDH/gi65hGhIF/NjuU4+S7uINNVh5ifOZY=";
  };

  nativeBuildInputs = [ cmake ];
  cmakeFlags = [ "-DPLUTOVG_BUILD_EXAMPLES=0" ];

  meta = with lib; {
    description = "Tiny 2D vector graphics library in C";
    homepage = "https://github.com/sammycage/plutovg";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
