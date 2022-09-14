{ lib, stdenv, fetchFromGitHub, libutf, ncurses }:

stdenv.mkDerivation rec {
  pname = "lchat";
  version = "2022-09-07";

  src = fetchFromGitHub {
    owner = "younix";
    repo = "lchat";
    rev = "fe93b05cea7431d7d240ae0d1d9842d288f66c4e";
    hash = "sha256-XRekfeCRCtYzy5n0NrILWCZXW6Y68W48PretW+yCtD4=";
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
