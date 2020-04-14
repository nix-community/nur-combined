{ mkDerivation
, lib
, pkgconfig
, qmake
, qtbase
, qtmultimedia
, qtsvg
, qttools
, qtx11extras
, libX11
, libXext
, libXtst
, sources
, withI18n ? true
}:

mkDerivation rec {
  pname = "redict";
  version = lib.substring 0 7 src.rev;
  src = sources.redict;

  nativeBuildInputs = [ qmake pkgconfig ] ++ (lib.optional withI18n qttools);
  buildInputs =
    [ qtbase qtmultimedia qtsvg qtx11extras libX11 libXext libXtst ];

  preConfigure = lib.optionalString withI18n ''
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
    inherit (src) description homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
