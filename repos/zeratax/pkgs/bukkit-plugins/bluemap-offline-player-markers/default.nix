{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "bluemap-offline-player-markers";
  version = "3.0";
  owner = "TechnicJelle";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://github.com/${owner}/BlueMapOfflinePlayerMarkers/releases/download/v${version}/BlueMapOfflinePlayerMarkers-${version}.jar";
      sha256 = "1f07w53q7yr4mvph7013d7ajxmp4lnsv6b1ab14y2x0bmqv39nwr";
    };
  in ''
    mkdir -p $out
    cp "${jar}" $out/${pname}.jar
  '';

  meta = with lib; {
    homepage = "https://github.com/TechnicJelle/BlueMapOfflinePlayerMarkers";
    description = "Minecraft Paper plugin and BlueMap addon that adds markers where players have logged off";
    maintainers = with maintainers; [zeratax];
  };
}
