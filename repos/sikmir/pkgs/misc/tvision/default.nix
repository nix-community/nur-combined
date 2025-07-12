{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ncurses,
}:

stdenv.mkDerivation {
  pname = "tvision";
  version = "0-unstable-2025-05-15";

  src = fetchFromGitHub {
    owner = "magiblot";
    repo = "tvision";
    rev = "df6424f1eee4f5fca9d5530118cab63e0a3c00fa";
    hash = "sha256-43CCUB9/O64xgi+nRPzA7Mi7HtsCUfn231DkEjVf0rY=";
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
