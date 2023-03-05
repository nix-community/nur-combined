{ lib, stdenv, fetchFromGitea, cmake, pkg-config, SDL2, the-foundation, AppKit }:

stdenv.mkDerivation rec {
  pname = "bwh";
  version = "2023-02-05";

  src = fetchFromGitea {
    domain = "git.skyjake.fi";
    owner = "skyjake";
    repo = "bwh";
    rev = "4b13d98f9aac38455ab1db9313af33211edd6ea0";
    hash = "sha256-oEIctSJEBxHuL6pBwbAb9PrIDcpMwYmjMIkpqhW+McY=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ SDL2 the-foundation ] ++ lib.optional stdenv.isDarwin AppKit;

  #cmakeFlags = [ "-Dthe_Foundation_DIR=${the-foundation}/lib/cmake/the_Foundation" ];

  meta = with lib; {
    description = "Bitwise Harmony - simple synth tracker";
    homepage = "https://git.skyjake.fi/skyjake/bwh";
    license = licenses.bsd2;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin; # AppKit 10.15 required
  };
}
