{ stdenv, sources }:

stdenv.mkDerivation {
  pname = "csvquote";
  version = stdenv.lib.substring 0 10 sources.csvquote.date;

  src = sources.csvquote;

  makeFlags = [ "BINDIR=$(out)/bin" ];

  preInstall = "mkdir -p $out/bin";

  meta = with stdenv.lib; {
    inherit (sources.csvquote) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
