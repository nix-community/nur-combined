{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ncurses,
}:

stdenv.mkDerivation {
  pname = "tvision";
  version = "0-unstable-2025-09-08";

  src = fetchFromGitHub {
    owner = "magiblot";
    repo = "tvision";
    rev = "6276f413079cf8da4a57058ec04b8531dedb02ec";
    hash = "sha256-tvrn4AfvQ44w64Agzyuhj8V+TgV89IuBmzAkb9gF5Vg=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ ncurses ];

  cmakeFlags = [ (lib.cmakeBool "TV_BUILD_EXAMPLES" false) ];

  meta = {
    description = "A modern port of Turbo Vision 2.0, the classical framework for text-based user interfaces";
    homepage = "https://github.com/magiblot/tvision";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
