{ lib, stdenv, fetchFromGitHub, libutf, ncurses }:

stdenv.mkDerivation rec {
  pname = "lchat";
  version = "2022-01-26";

  src = fetchFromGitHub {
    owner = "younix";
    repo = "lchat";
    rev = "adcc7010548fdd11b1d80e1da1d9410c4d8e095b";
    hash = "sha256-fiyempu1ay7TP0cCWzaAQBPMxljIVCJoYUHlZ37S1hA=";
  };

  buildInputs = [ libutf ncurses ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  preInstall = "mkdir -p $out/bin $out/share/man/man1";

  meta = with lib; {
    description = "line chat is a simple and elegant front end for ii-like chat programs";
    inherit (src.meta) homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
