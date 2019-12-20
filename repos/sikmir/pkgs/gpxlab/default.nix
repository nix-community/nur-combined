{ mkDerivation, lib, qmake, qtbase, qttools, qttranslations, GPXLab }:

mkDerivation rec {
  pname = "gpxlab";
  version = lib.substring 0 7 src.rev;
  src = GPXLab;

  nativeBuildInputs = [ qmake qttools ];
  buildInputs = [ qtbase qttranslations ];

  preConfigure = ''
    lrelease GPXLab/locale/*.ts
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    homepage = "https://github.com/BourgeoisLab/GPXLab";
    description = GPXLab.description;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
