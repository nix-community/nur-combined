{ mkDerivation, lib, pkgconfig, qmake, qtbase, qtmultimedia, qtsvg, qttools
, qtx11extras, libX11, libXext, libXtst, redict }:

mkDerivation rec {
  pname = "redict";
  version = lib.substring 0 7 src.rev;
  src = redict;

  nativeBuildInputs = [ qmake qttools pkgconfig ];
  buildInputs =
    [ qtbase qtmultimedia qtsvg qtx11extras libX11 libXext libXtst ];

  preConfigure = ''
    lupdate redict.pro
    lrelease redict.pro
  '';

  qmakeFlags = [
    "PREFIX=${placeholder "out"}"
    "BINDIR=${placeholder "out"}/bin"
    "APPDIR=${placeholder "out"}/share/applications"
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = redict.description;
    homepage = redict.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
