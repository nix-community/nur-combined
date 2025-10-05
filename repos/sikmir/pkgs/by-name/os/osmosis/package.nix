{
  lib,
  stdenv,
  fetchfromgh,
  jre,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osmosis";
  version = "0.49.2";

  src = fetchfromgh {
    owner = "openstreetmap";
    repo = "osmosis";
    tag = finalAttrs.version;
    hash = "sha256-aVDx39vkM3rRk7BQEwk1FCbEA/q3cAYcndypoorvwm0=";
    name = "osmosis-${finalAttrs.version}.zip";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out
    cp -r . $out
    rm $out/bin/*.bat
    substituteInPlace $out/bin/osmosis \
      --replace-fail "JAVACMD=java" "JAVACMD=${jre}/bin/java"
  '';

  meta = {
    description = "Command line Java application for processing OSM data";
    homepage = "http://wiki.openstreetmap.org/wiki/Osmosis";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = jre.meta.platforms;
  };
})
