{ lib, stdenv, fetchFromGitHub, autoreconfHook, autoconf-archive, ncurses, pkg-config }:

stdenv.mkDerivation (finalAttrs: {
  pname = "finalcut";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "gansm";
    repo = "finalcut";
    rev = finalAttrs.version;
    hash = "sha256-fRAzfvuqruveb229fV0XYh764cA26NlDVXxX+3Fobg4=";
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
