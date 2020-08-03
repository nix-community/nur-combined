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
  pname = "gpxsee";
  date = lib.substring 0 10 sources.gpxsee.date;
  version = "unstable-" + date;
in
mkDerivation {
  inherit pname version;
  src = sources.gpxsee;

  patches = (substituteAll {
    # See https://github.com/NixOS/nixpkgs/issues/86054
    src = ./fix-qttranslations-path.patch;
    inherit qttranslations;
  });

  postPatch = ''
    sed -i "s/\(VERSION = \).*/\1${version}/" gpxsee.pro
  '';

  nativeBuildInputs = [ qmake ] ++ (lib.optional withI18n qttools);
  buildInputs = [ qtbase ];

  preConfigure = lib.optionalString withI18n ''
    lrelease gpxsee.pro
  '';

  postInstall = lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    mv GPXSee.app $out/Applications
    wrapQtApp $out/Applications/GPXSee.app/Contents/MacOS/GPXSee
    mkdir -p $out/bin
    ln -s $out/Applications/GPXSee.app/Contents/MacOS/GPXSee $out/bin/gpxsee
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    inherit (sources.gpxsee) description homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    skip.ci = stdenv.isDarwin;
  };
}
