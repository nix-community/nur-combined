{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "voicechat-interaction-paper";
  version = "1.3.1";
  owner = " igalaxy";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://cdn.modrinth.com/data/MEPADOya/versions/wVSaDcGA/voicechat-interaction-paper-v1.3.1%2B1.20.2.jar";
      sha256 = "0fqksszha9f64a5b6lz1wa0vlp4xdyyjf6xx82f9hhdinlxmk8am";
    };
  in ''
    mkdir -p $out
    cp ${jar} $out/${pname}.jar
  '';

  meta = with lib; {
    homepage = "https://modrinth.com/plugin/voice-chat-interaction-paper";
    description = "Third-party Paper port of henkelmax's voicechat-interaction serverside Fabric mod";
    maintainers = with maintainers; [zeratax];
  };
}
