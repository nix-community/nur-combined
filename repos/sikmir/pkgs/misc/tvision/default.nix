{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ncurses,
}:

stdenv.mkDerivation {
  pname = "tvision";
  version = "0-unstable-2024-02-28";

  src = fetchFromGitHub {
    owner = "magiblot";
    repo = "tvision";
    rev = "d1fa783e0fa8685c199563a466cdc221e8d9b85c";
    hash = "sha256-MEAGs/PhLPmmn7+9J2DbZm+FhrXBZynv38JdAptxtLA=";
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
