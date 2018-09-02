{ stdenv, fetchurl, makeWrapper, jre, openal }:

let version = "4.355"; in

stdenv.mkDerivation {
  name = "technic-launcher-${version}";

  jar = fetchurl {
    url = "http://launcher.technicpack.net/launcher${stdenv.lib.replaceStrings ["."] ["/"] version}/TechnicLauncher.jar";
    sha256 = "0f6f094d7m7bhg7h4fwpv1iillp5fsmk3rwy06lmg9pfp9gq9ixc";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ openal ];

  phases = "installPhase";

  installPhase = ''
    mkdir -p $out/share/java
    ln -s $jar $out/share/java/technic.jar
    makeWrapper ${jre}/bin/java $out/bin/technic --add-flags "-jar $out/share/java/technic.jar" --prefix LD_LIBRARY_PATH : ${openal}/lib
  '';

  meta = with stdenv.lib; {
    description = "Minecraft Mod Launcher";
    homepage = https://www.technicpack.net/;
    license = licenses.unfree;
  };
}
