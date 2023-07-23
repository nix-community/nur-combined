{ lib, stdenv, fetchFromGitHub, cmake, ncurses }:

stdenv.mkDerivation rec {
  pname = "tvision";
  version = "2023-06-22";

  src = fetchFromGitHub {
    owner = "magiblot";
    repo = "tvision";
    rev = "92177cb365b523b0bc3e17d865292045ed7e0073";
    hash = "sha256-6Itw1Uy9AXY5Zi+eBSMBtqft7xF+rYApLdH6dgSfepE=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ ncurses ];

  meta = with lib; {
    description = "A modern port of Turbo Vision 2.0, the classical framework for text-based user interfaces";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
