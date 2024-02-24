{ lib, stdenv, fetchFromGitHub, cmake, ncurses }:

stdenv.mkDerivation rec {
  pname = "tvision";
  version = "0-unstable-2024-02-05";

  src = fetchFromGitHub {
    owner = "magiblot";
    repo = "tvision";
    rev = "be6e64f85355c6c96b7c09174986fafb6a411c6a";
    hash = "sha256-ngI5VX2SwLdKYLqD65/B93ZhNhHZWaAkIRgF3LLaRxM=";
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
