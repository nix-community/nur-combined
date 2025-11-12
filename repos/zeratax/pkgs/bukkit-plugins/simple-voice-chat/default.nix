{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "SimpleVoiceChat";
  version = "2.6.6";
  owner = "henkelmax";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://hangarcdn.papermc.io/plugins/${owner}/${pname}/versions/bukkit-${version}/PAPER/voicechat-bukkit-${version}.jar";
      sha256 = "0d9dfm7aivwy8bj2sni6mbxdqmyg0931n80kv9jylw838mh4m2p4";
    };
  in ''
    mkdir -p $out
    cp ${jar} $out/${pname}.jar
  '';

  meta = with lib; {
    homepage = "https://modrepo.de/minecraft/voicechat/overview";
    description = "A working voice chat in Minecraft!";
    maintainers = with maintainers; [zeratax];
  };
}
