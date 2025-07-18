{
  lib,
  stdenv,
  fetchurl,
  nixosTests,
  jre_headless,
  makeWrapper,
  version,
  hash,
}:

stdenv.mkDerivation {
  pname = "purpur";
  inherit version;

  src = fetchurl {
    url = "https://meta.fabricmc.net/v2/versions/loader/${
      builtins.replaceStrings [ "-" ] [ "/" ] version
    }/server/jar";
    sha256 = hash;
  };

  nativeBuildInputs = [ makeWrapper ];

  preferLocalBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/minecraft
    cp -v $src $out/lib/minecraft/server.jar

    makeWrapper ${jre_headless}/bin/java $out/bin/minecraft-server \
      --add-flags "-jar $out/lib/minecraft/server.jar nogui"
  '';

  dontUnpack = true;

  passthru = {
    updateScript = ./update.py;
    tests = { inherit (nixosTests) minecraft-server; };
  };

  allowSubstitutes = false;

  meta = with lib; {
    description = "Fabric enabled Minecraft server";
    longDescription = ''
      The executable jar is a small launcher that will start the Fabric enabled Minecraft server using the versions specified.
      There is no need to use an installer when using this method.
    '';
    homepage = "https://fabricmc.net/";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = [ ];
    mainProgram = "minecraft-server";
  };
}
