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

mkDerivation rec {
  pname = "gpxlab-unstable";
  version = lib.substring 0 10 sources.gpxlab.date;

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

  meta = with lib; {
    inherit (sources.gpxlab) description homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
