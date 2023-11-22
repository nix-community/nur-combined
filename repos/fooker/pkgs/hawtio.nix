{ stdenv
, fetchurl
, jre
, makeWrapper
, ... }:

stdenv.mkDerivation rec {
  pname = "hawtio";
  version = "3.0-M6";

  src = fetchurl {
    url = "https://repo1.maven.org/maven2/io/hawt/hawtio-app/${version}/hawtio-app-${version}.jar";
    hash = "sha256-hy3eKM4bgFAHCm5MJskYmjtoHO5etrEUnL/1ZWscKHM=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/java}

    cp $src $out/share/java/hawtio-${version}.jar

    makeWrapper ${jre}/bin/java $out/bin/hawtio \
      --add-flags "--add-modules jdk.attach" \
      --add-flags "-Dhawtio.localAddressProbing=false" \
      --add-flags "-jar \"$out/share/java/hawtio-${version}.jar\""

    runHook postInstall
  '';

  nativeBuildInputs = [ makeWrapper ];
}
