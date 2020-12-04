{ stdenv, fetchurl, jre }:
stdenv.mkDerivation {
  pname = "papermc";
  version = "1.15.2";

  src = fetchurl {
    url = "https://papermc.io/api/v1/paper/1.15.2/126/download";
    sha256 = "138qaqkacn3dz16qy13vd0pj6x2xj89xswyd8ap3ra0hm9amalvv";
  };

  preferLocalBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/minecraft
    cp -v $src $out/lib/minecraft/server.jar
    cat > $out/bin/minecraft-server << EOF
    #!/bin/sh
    exec ${jre}/bin/java \$@ -jar $out/lib/minecraft/server.jar --nogui
    EOF
    chmod +x $out/bin/minecraft-server
  '';

  phases = "installPhase";

  meta = {
    description = "PaperMC Minecraft Server";
    homepage = "https://papermc.io/";
    license = stdenv.lib.licenses.gpl3;
  };
}
