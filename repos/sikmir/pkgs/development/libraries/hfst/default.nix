{ stdenv, autoreconfHook, bison, flex, sources }:
let
  pname = "hfst";
  date = stdenv.lib.substring 0 10 sources.hfst.date;
  version = "unstable-" + date;
in
stdenv.mkDerivation {
  inherit pname version;
  src = sources.hfst;

  nativeBuildInputs = [ autoreconfHook bison flex ];

  meta = with stdenv.lib; {
    inherit (sources.hfst) description homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
