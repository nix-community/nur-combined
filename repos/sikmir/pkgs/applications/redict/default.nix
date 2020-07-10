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
  pname = "redict";
  version = lib.substring 0 7 sources.redict.rev;
  src = sources.redict;

  nativeBuildInputs = [ qmake pkgconfig ] ++ (lib.optional withI18n qttools);
  buildInputs =
    [ qtbase qtmultimedia qtsvg ] ++ (lib.optionals stdenv.isLinux [ qtx11extras libX11 libXext libXtst ]);

  postPatch = ''
    substituteInPlace redict.pro \
      --replace "unix " "unix:!mac "
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

  enableParallelBuilding = true;

  meta = with lib; {
    inherit (sources.redict) description homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = with platforms; linux ++ darwin;
    broken = stdenv.isDarwin;
  };
}
