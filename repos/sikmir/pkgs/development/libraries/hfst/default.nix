{ stdenv, autoreconfHook, bison, flex, sources }:

stdenv.mkDerivation {
  pname = "hfst";
  version = stdenv.lib.substring 0 7 sources.hfst.rev;
  src = sources.hfst;

  nativeBuildInputs = [ autoreconfHook bison flex ];

  meta = with stdenv.lib; {
    inherit (sources.hfst) description homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
