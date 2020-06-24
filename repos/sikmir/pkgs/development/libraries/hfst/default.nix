{ stdenv, autoreconfHook, bison, flex, sources }:

stdenv.mkDerivation rec {
  pname = "hfst";
  version = stdenv.lib.substring 0 7 src.rev;
  src = sources.hfst;

  nativeBuildInputs = [ autoreconfHook bison flex ];

  meta = with stdenv.lib; {
    inherit (src) description homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
