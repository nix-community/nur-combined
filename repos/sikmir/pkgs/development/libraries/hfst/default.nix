{ lib, stdenv, autoreconfHook, bison, flex, sources }:

stdenv.mkDerivation {
  pname = "hfst-unstable";
  version = lib.substring 0 10 sources.hfst.date;

  src = sources.hfst;

  nativeBuildInputs = [ autoreconfHook bison flex ];

  meta = with lib; {
    inherit (sources.hfst) description homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
