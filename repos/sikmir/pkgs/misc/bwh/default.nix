{ lib, stdenv, fetchFromGitea, cmake, pkg-config, SDL2, the-foundation, AppKit }:

stdenv.mkDerivation rec {
  pname = "bwh";
  version = "1.0.3";

  src = fetchFromGitea {
    domain = "git.skyjake.fi";
    owner = "skyjake";
    repo = "bwh";
    rev = "v${version}";
    hash = "sha256-POKjvUGFS3urc1aqOvfCAApUnRxoZhU725eYRAS4Z2w=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ SDL2 the-foundation ] ++ lib.optional stdenv.isDarwin AppKit;

  #cmakeFlags = [
  #  (lib.cmakeFeature "the_Foundation_DIR" "${the-foundation}/lib/cmake/the_Foundation")
  #];

  meta = with lib; {
    description = "Bitwise Harmony - simple synth tracker";
    homepage = "https://git.skyjake.fi/skyjake/bwh";
    license = licenses.bsd2;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin; # AppKit 10.15 required
  };
}
