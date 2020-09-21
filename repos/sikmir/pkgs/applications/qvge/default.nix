{ lib
, stdenv
, mkDerivation
, substituteAll
, ogdf
, qmake
, qtx11extras
, sources
}:
let
  pname = "qvge";
  date = lib.substring 0 10 sources.qvge.date;
  version = "unstable-" + date;
in
mkDerivation {
  inherit pname version;
  src = sources.qvge;

  patches = (substituteAll {
    src = ./fix-config.patch;
    inherit ogdf;
  });

  preConfigure = "cd src";

  nativeBuildInputs = [ qmake ];

  buildInputs = [ ogdf qtx11extras ];

  qmakeFlags = [ "-r" ];

  meta = with lib; {
    inherit (sources.qvge) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = with platforms; linux;
    skip.ci = stdenv.isDarwin;
  };
}
