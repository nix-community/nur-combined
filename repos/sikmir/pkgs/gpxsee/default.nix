{ mkDerivation, lib, qmake, qtbase, qttools, qttranslations, GPXSee }:

mkDerivation rec {
  pname = "gpxsee";
  version = lib.substring 0 7 src.rev;
  src = GPXSee;

  nativeBuildInputs = [ qmake qttools ];
  buildInputs = [ qtbase qttranslations ];

  preConfigure = ''
    lrelease lang/*.ts
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    homepage = "https://www.gpxsee.org/";
    description = GPXSee.description;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
