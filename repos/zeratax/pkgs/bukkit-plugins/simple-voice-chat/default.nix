{ lib, stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "SimpleVoiceChat";
  version = "2.5.20";
  owner = "henkelmax";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://hangarcdn.papermc.io/plugins/${owner}/${pname}/versions/${version}/PAPER/voicechat-bukkit-${version}.jar";
      sha256 = "023wjx0zxf9rc2x9vsqg398wapz0nlwfs5g6c8pci3qx75i5s4jx";
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
