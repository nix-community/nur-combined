{ mkDerivation, lib, qmake, qtbase, qttools, qttranslations, gpxlab }:

mkDerivation rec {
  pname = "gpxlab";
  version = lib.substring 0 7 src.rev;
  src = gpxlab;

  nativeBuildInputs = [ qmake qttools ];
  buildInputs = [ qtbase qttranslations ];

  preConfigure = ''
    lrelease GPXLab/locale/*.ts
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    homepage = gpxlab.homepage;
    description = gpxlab.description;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
