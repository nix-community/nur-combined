{
  lib,
  stdenv,
  fetchFromGitHub,
  chez,
  libuuid,
  lz4,
  ncurses,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "schemesh";
  version = "0.9.2-unstable-2025-10-30";

  src = fetchFromGitHub {
    owner = "cosmos72";
    repo = "schemesh";
    rev = "e5bb172238179ba769398150c856d8f16407626a";
    hash = "sha256-9qBIV3O5uU5Wouiy4roe0UW1bNJYJ0l0EySYdWZcX80=";
  };

  buildInputs = [
    chez
    libuuid
    lz4
    ncurses
    zlib
  ];

  makeFlags = [ "prefix=$(out)" ];

  meta = {
    description = "A Unix shell and Lisp REPL, fused together";
    homepage = "https://github.com/cosmos72/schemesh";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
