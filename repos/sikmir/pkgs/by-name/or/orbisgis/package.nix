{
  lib,
  stdenv,
  fetchfromgh,
  unzip,
  rsync,
  makeWrapper,
  jre8,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "orbisgis";
  version = "5.1.0";

  src = fetchfromgh {
    owner = "orbisgis";
    repo = "orbisgis";
    tag = "${finalAttrs.version}-SNAPSHOT";
    hash = "sha256-e7SSn+P8rF5eSbl4Z/zp1mHNN2rAi4ZoMvkoy360hGM=";
    name = "orbisgis-bin.zip";
  };

  nativeBuildInputs = [
    unzip
    rsync
    makeWrapper
  ];

  postPatch = ''
    sed -i "s#/usr/bin/orbisgis#$out/bin/orbisgis#" orbisgis.desktop
    sed -i "s#/usr/lib/OrbisGIS#$out/opt/OrbisGIS#" orbisgis orbisgis.desktop
    sed -i "s#java -jar#${jre8}/bin/java -jar#" orbisgis.sh orbisgis_safemode.sh
  '';

  installPhase = ''
    mkdir -p $out/{bin,opt/OrbisGIS}
    rsync -r --exclude '*.bat' . $out/opt/OrbisGIS

    chmod +x $out/opt/OrbisGIS/orbisgis
    makeWrapper $out/opt/OrbisGIS/orbisgis $out/bin/orbisgis \
      --set JAVA_HOME "${jre8}"
  '';

  meta = {
    homepage = "http://orbisgis.org/";
    description = "An opensource GIS software";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = jre8.meta.platforms;
    skip.ci = true;
  };
})
