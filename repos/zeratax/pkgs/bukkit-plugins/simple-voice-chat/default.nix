{ lib, stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "SimpleVoiceChat";
  version = "2.4.28";
  owner = "henkelmax";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://hangarcdn.papermc.io/plugins/${owner}/${pname}/versions/${version}/PAPER/voicechat-bukkit-${version}.jar";
      sha256 = "0sciv9nkkg3sdp1217mf7n4d5ixzi21fmwalzxdybwqr8vyqp5vs";
    };
  in ''
    mkdir -p $out
    cp ${jar} $out/${pname}.jar
  '';

  meta = with lib; {
    homepage = "https://modrepo.de/minecraft/voicechat/overview";
    description =
      "A working voice chat in Minecraft!";
    maintainers = with maintainers; [ zeratax ];
  };
}
