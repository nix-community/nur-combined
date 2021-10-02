{ lib, stdenv, fetchurl, unzip, wine, writers }:
let
  runScript = writers.writeBash "gpxeditor" ''
    export WINEDEBUG=warn+all
    ${wine}/bin/wine @out@/GPX_Editor.exe
  '';
in
stdenv.mkDerivation rec {
  pname = "gpxeditor";
  version = "1.7.15";

  src = fetchurl {
    url = "mirror://sourceforge/gpxeditor/GPX%20Editor/Version%20${version}/GPX_Editor_${lib.replaceStrings [ "." ] [ "_" ] version}.zip";
    hash = "sha256-laGJU8LHNNoUoVyHY2IaCXGpFmgOLSrWe/lCz5Tzjj4=";
  };

  dontUnpack = true;

  installPhase = ''
    install -dm755 $out/bin
    substitute ${runScript} $out/bin/gpxeditor --subst-var out
    chmod +x $out/bin/gpxeditor

    ${unzip}/bin/unzip $src -d $out
  '';

  preferLocalBuild = true;

  meta = with lib; {
    description = "Load, modify and save your GPX files";
    homepage = "https://sourceforge.net/projects/gpxeditor/";
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
