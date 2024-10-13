{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "plutovg";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "plutovg";
    rev = "v${version}";
    hash = "sha256-LzVZL/5lUKZSWUyCt3nOwoq0oZxmf1JDCy7/MkRVxlw=";
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
