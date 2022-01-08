{ lib, stdenv, fetchFromGitHub, libgrapheme }:

stdenv.mkDerivation rec {
  pname = "makel";
  version = "2022-01-07";

  src = fetchFromGitHub {
    owner = "maandree";
    repo = pname;
    rev = "7e54065eb147ba61b5c4b0ca81bd3980a91bf22d";
    hash = "sha256-U+0ou4FZvqs+/gL8mMrrdmioP/up9V8+P5DH9xgzV9M=";
  };

  buildInputs = [ libgrapheme ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  installPhase = ''
    install -Dm755 makel $out/bin/makel
  '';

  meta = with lib; {
    description = "Makefile linter";
    inherit (src.meta) homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
