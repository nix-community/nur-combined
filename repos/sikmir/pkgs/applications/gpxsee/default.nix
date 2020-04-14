{ stdenv, mkDerivation, lib, qmake, qtbase, qttools, qttranslations, sources
, withI18n ? true }:

mkDerivation rec {
  pname = "gpxsee";
  version = lib.substring 0 7 src.rev;
  src = sources.gpxsee;

  nativeBuildInputs = [ qmake ] ++ (lib.optional withI18n qttools);
  buildInputs = [ qtbase ];

  preConfigure = lib.optionalString withI18n ''
    lrelease lang/*.ts
  '';

  postInstall = lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    mv GPXSee.app $out/Applications
    wrapQtApp $out/Applications/GPXSee.app/Contents/MacOS/GPXSee
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = with platforms; linux ++ darwin;
  };
}
