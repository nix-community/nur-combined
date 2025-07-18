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
  pname = "neoforge";
  inherit version;

  src = let
    build_version = lib.last (lib.strings.split "-" version);
  in fetchurl {
    url = "https://maven.neoforged.net/releases/net/neoforged/neoforge/${build_version}/neoforge-${build_version}-installer.jar";
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
    description = "Neoforge enabled Minecraft server";
    longDescription = ''
      Neoforge is a Minecraft mod loader that provides a more modern and efficient way to run Minecraft servers.
    '';
    homepage = "https://neoforged.net/";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.lgpl21;
    platforms = platforms.unix;
    maintainers = [ ];
    mainProgram = "minecraft-server";
  };
}
