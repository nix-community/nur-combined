{ stdenv, sources }:

stdenv.mkDerivation {
  pname = "csvquote";
  version = stdenv.lib.substring 0 7 sources.csvquote.rev;
  src = sources.csvquote;

  makeFlags = [ "BINDIR=$(out)/bin" ];

  preInstall = "mkdir -p $out/bin";

  meta = with stdenv.lib; {
    inherit (sources.csvquote) description homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = with platforms; linux ++ darwin;
  };
}
