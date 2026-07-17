{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ncurses,
}:

stdenv.mkDerivation {
  pname = "tvision";
  version = "0-unstable-2026-05-12";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "magiblot";
    repo = "tvision";
    rev = "57b6f56b38e0ee75240a80a10ee0e11470c24693";
    hash = "sha256-X9KM39OsdL4ZlXPZQv+sIvrZcMSQ23uMx5xZmB0gGDU=";
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
