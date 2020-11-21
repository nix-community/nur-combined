{ mkDerivation
, stdenv
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

mkDerivation {
  pname = "redict-unstable";
  version = lib.substring 0 10 sources.redict.date;

  src = sources.redict;

  nativeBuildInputs = [ qmake pkgconfig ]
    ++ lib.optional withI18n qttools;
  buildInputs = [ qtmultimedia qtsvg ]
    ++ lib.optionals stdenv.isLinux [ qtx11extras libX11 libXext libXtst ];

  postPatch = ''
    substituteInPlace redict.pro \
      --replace "unix " "unix:!mac "
    sed -i '1i#include <QPainterPath>' src/widgets/spinner.cpp
  '';

  preConfigure = lib.optionalString withI18n ''
    lupdate redict.pro
    lrelease redict.pro
  '';

  qmakeFlags = [
    "PREFIX=${placeholder "out"}"
    "BINDIR=${placeholder "out"}/bin"
    "APPDIR=${placeholder "out"}/share/applications"
  ];

  meta = with lib; {
    inherit (sources.redict) description homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin;
  };
}
