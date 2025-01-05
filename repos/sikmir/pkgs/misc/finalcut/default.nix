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
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "gansm";
    repo = "finalcut";
    tag = finalAttrs.version;
    hash = "sha256-iKLE4UMDbnsKYEjQHlF+xyZSBke1EZSVJiabbKRkzhg=";
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
