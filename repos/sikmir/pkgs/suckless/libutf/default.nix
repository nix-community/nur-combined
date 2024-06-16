{
  lib,
  stdenv,
  fetchFromGitHub,
  libutf,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libutf";
  version = "0.1-unstable-2018-11-13";

  src = fetchFromGitHub {
    owner = "cls";
    repo = "libutf";
    rev = "ee5074db68f498a5c802dc9f1645f396c219938a";
    hash = "sha256-pgiomcCM3PKNdryj4F6DuH3EI8dTKOIt1hr2AvBXIoQ=";
  };

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Plan 9 compatible UTF-8 C library";
    homepage = "https://github.com/cls/libutf";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
