{ stdenv, sources }:
let
  pname = "csvquote";
  date = stdenv.lib.substring 0 10 sources.csvquote.date;
  version = "unstable-" + date;
in
stdenv.mkDerivation {
  inherit pname version;
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
