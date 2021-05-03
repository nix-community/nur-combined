{ lib, stdenv, fetchurl, jre_headless, minecraft-server }:

stdenv.mkDerivation rec {
  pname = "minecraft-server-fabric";
  version = "0.6.1.51";

  src = fetchurl {
    url = "https://maven.fabricmc.net/net/fabricmc/fabric-installer/${version}/fabric-installer-${version}.jar";
    sha256 = "0cima0n3b37qha9a16kcvjnx9mg231v5wdg1063gxnq3vrxlcw23";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ jre_headless ];

  installPhase = ''
    mkdir -p $out/bin $out/lib/minecraft-fabric
    cp ${minecraft-server}/lib/minecraft/server.jar $out/lib/minecraft-fabric/server.jar
    cp -v $src $out/lib/minecraft-fabric/fabric-installer-${version}.jar
    pushd $out/lib/minecraft-fabric
    ${jre_headless}/bin/java -jar fabric-installer-${version}.jar server
    popd
    cat > $out/bin/minecraft-server-fabric << EOF
    #!/bin/sh
    exec ${jre_headless}/bin/java \$@ -jar $out/lib/minecraft-fabric/fabric-server-launch.jar nogui
    EOF
    chmod +x $out/bin/minecraft-server
  '';

  phases = "installPhase";
  
  meta = with lib; {
    description = "minecraft with the fabric modloader";
    license = licenses.unfree;
    platforms = platforms.all;
    
    broken = true;
  };

}
