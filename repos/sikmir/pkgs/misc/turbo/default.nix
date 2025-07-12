{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  file,
  tvision,
}:

stdenv.mkDerivation {
  pname = "turbo";
  version = "0-unstable-2025-05-15";

  src = fetchFromGitHub {
    owner = "magiblot";
    repo = "turbo";
    rev = "b6b19535af7d0d01d77ec0ddcbe731fe8b0ddda7";
    hash = "sha256-rqRRO3wafpL8ZEzIV8iO4gvdJpjixmb+F7MILJtOjIc=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    file # libmagic
    tvision
  ];

  cmakeFlags = [ (lib.cmakeBool "TURBO_USE_SYSTEM_TVISION" true) ];

  meta = {
    description = "An experimental text editor based on Scintilla and Turbo Vision";
    homepage = "https://github.com/magiblot/turbo";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
