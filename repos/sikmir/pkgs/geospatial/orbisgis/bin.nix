{ lib, stdenv, fetchfromgh, unzip, rsync, makeWrapper, jre }:

stdenv.mkDerivation rec {
  pname = "orbisgis-bin";
  version = "5.1.0";

  src = fetchfromgh {
    owner = "orbisgis";
    repo = "orbisgis";
    name = "orbisgis-bin.zip";
    version = "${version}-SNAPSHOT";
    hash = "sha256-e7SSn+P8rF5eSbl4Z/zp1mHNN2rAi4ZoMvkoy360hGM=";
  };

  nativeBuildInputs = [ unzip rsync makeWrapper ];

  postPatch = ''
    sed -i "s#/usr/bin/orbisgis#$out/bin/orbisgis#" orbisgis.desktop
    sed -i "s#/usr/lib/OrbisGIS#$out/opt/OrbisGIS#" orbisgis orbisgis.desktop
    sed -i "s#java -jar#${jre}/bin/java -jar#" orbisgis.sh orbisgis_safemode.sh
  '';

  installPhase = ''
    mkdir -p $out/{bin,opt/OrbisGIS}
    rsync -r --exclude '*.bat' . $out/opt/OrbisGIS

    chmod +x $out/opt/OrbisGIS/orbisgis
    makeWrapper $out/opt/OrbisGIS/orbisgis $out/bin/orbisgis \
      --set JAVA_HOME "${jre}"
  '';

  meta = with lib; {
    homepage = "http://orbisgis.org/";
    description = "An opensource GIS software";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = jre.meta.platforms;
    skip.ci = true;
  };
}
