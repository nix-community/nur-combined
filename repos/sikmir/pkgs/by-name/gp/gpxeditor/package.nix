{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wine,
  writers,
}:
let
  runScript = writers.writeBash "gpxeditor" ''
    export WINEDEBUG=warn+all
    ${wine}/bin/wine @out@/GPX_Editor.exe
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gpxeditor";
  version = "1.8.0";

  src = fetchurl {
    url = "mirror://sourceforge/gpxeditor/GPX%20Editor/GPX%20Editor%20${finalAttrs.version}.zip";
    hash = "sha256-KgVwx79kOQzXJQaQK1VRWHJHIU4yBpCH/7pFh7G4D54=";
  };

  dontUnpack = true;

  installPhase = ''
    install -dm755 $out/bin
    substitute ${runScript} $out/bin/gpxeditor --subst-var out
    chmod +x $out/bin/gpxeditor

    ${unzip}/bin/unzip $src -d $out
  '';

  preferLocalBuild = true;

  meta = {
    description = "Load, modify and save your GPX files";
    homepage = "https://sourceforge.net/projects/gpxeditor/";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
})
