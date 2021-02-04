{ lib, stdenv, sources }:

stdenv.mkDerivation {
  pname = "csvquote";
  version = lib.substring 0 10 sources.csvquote.date;

  src = sources.csvquote;

  makeFlags = [ "BINDIR=$(out)/bin" ];

  preInstall = "mkdir -p $out/bin";

  meta = with lib; {
    inherit (sources.csvquote) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
