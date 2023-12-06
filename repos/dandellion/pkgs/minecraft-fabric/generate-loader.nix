{ lib, fetchurl, stdenv, unzip, zip, jre_headless }:

let
  lock = import ./lock.nix;
  libraries = lib.forEach lock.libraries fetchurl;
in
stdenv.mkDerivation {
  name = "fabric-server-launch.jar";
  nativeBuildInputs = [ unzip zip jre_headless ];

  libraries = libraries;

  buildPhase = ''
    for i in $libraries; do
      unzip -o $i
    done

    cat > META-INF/MANIFEST.MF << EOF
    Manifest-Version: 1.0
    Main-Class: net.fabricmc.loader.impl.launch.server.FabricServerLauncher
    EOF

    cat > fabric-server-launch.properties << EOF
    launch.mainClass=net.fabricmc.loader.impl.launch.knot.KnotServer
    EOF
  '';

  installPhase = ''
    jar cmvf META-INF/MANIFEST.MF "server.jar" .
    zip -d server.jar 'META-INF/*.SF' 'META-INF/*.RSA' 'META-INF/*.DSA'
    cp server.jar "$out"
  '';

  phases = [ "buildPhase" "installPhase" ];
}
