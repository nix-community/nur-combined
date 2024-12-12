{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  autoconf-archive,
  ncurses,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "finalcut";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "gansm";
    repo = "finalcut";
    tag = finalAttrs.version;
    hash = "sha256-fRAzfvuqruveb229fV0XYh764cA26NlDVXxX+3Fobg4=";
  };

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    pkg-config
  ];

  buildInputs = [ ncurses ];

  meta = {
    description = "A text-based widget toolkit";
    homepage = "https://github.com/gansm/finalcut";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
