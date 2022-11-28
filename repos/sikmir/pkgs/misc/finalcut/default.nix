{ lib, stdenv, fetchFromGitHub, autoreconfHook, autoconf-archive, ncurses, pkg-config }:

stdenv.mkDerivation (finalAttrs: {
  pname = "finalcut";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "gansm";
    repo = "finalcut";
    rev = finalAttrs.version;
    hash = "sha256-FaloxuRx9p9oMyuKyJhYZve/WyQoMSGTYwY6A2uE0F0=";
  };

  nativeBuildInputs = [ autoreconfHook autoconf-archive pkg-config ];

  buildInputs = [ ncurses ];

  meta = with lib; {
    description = "A text-based widget toolkit";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.lgpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
