{ stdenv
, mkDerivation
, lib
, qmake
, qtbase
, qttools
, qttranslations
, sources
, substituteAll
, withI18n ? true
}:
let
  pname = "gpxlab";
  date = lib.substring 0 10 sources.gpxlab.date;
  version = "unstable-" + date;
in
mkDerivation {
  inherit pname version;
  src = sources.gpxlab;

  patches = (substituteAll {
    # See https://github.com/NixOS/nixpkgs/issues/86054
    src = ./fix-qttranslations-path.patch;
    inherit qttranslations;
  });

  postPatch = ''
    sed -i "s/\(VERSION = \).*/\1${version}/" GPXLab/GPXLab.pro
  '';

  nativeBuildInputs = [ qmake ] ++ (lib.optional withI18n qttools);
  buildInputs = [ qtbase ];

  preConfigure = lib.optionalString withI18n ''
    lrelease GPXLab/locale/*.ts
  '';

  postInstall = lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    mv GPXLab/GPXLab.app $out/Applications
    wrapQtApp $out/Applications/GPXLab.app/Contents/MacOS/GPXLab
    mkdir -p $out/bin
    ln -s $out/Applications/GPXLab.app/Contents/MacOS/GPXLab $out/bin/gpxlab
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    inherit (sources.gpxlab) description homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = with platforms; linux ++ darwin;
  };
}
