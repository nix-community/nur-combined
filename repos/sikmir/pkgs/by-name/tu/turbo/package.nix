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
  version = "0-unstable-2025-08-26";

  src = fetchFromGitHub {
    owner = "magiblot";
    repo = "turbo";
    rev = "695175f96462f4dc9f1411de552b321f0ef1eccb";
    hash = "sha256-vXRde44RvXYXpPAbKms38RpvGcGCV7wAfdQdjxoBtcQ=";
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
