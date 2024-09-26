{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "bluemap-marker-manger";
  version = "2.1.5";
  owner = "MiraculixxT";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://cdn.modrinth.com/data/a8UoyV2h/versions/E0XoPfJV/BMM-2.1.5.jar";
      sha256 = "1vpnqglybysxnqyzkjnwbwg000dqkbk516apzvhmg39wlfaysl9d";
    };
  in ''
    mkdir -p $out
    echo "${jar}"
    cp "${jar}" $out/${pname}.jar
  '';

  meta = with lib; {
    homepage = "https://modrinth.com/plugin/bmarker";
    description = "BlueMap extension - Add a marker command to easily setup your markers & marker sets ingame without touching any configs";
    maintainers = with maintainers; [zeratax];
  };
}
