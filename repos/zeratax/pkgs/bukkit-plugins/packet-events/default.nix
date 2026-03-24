{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "packet-events";
  version = "2.11.2";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://cdn.modrinth.com/data/HYKaKraK/versions/YjTc55NR/packetevents-spigot-${version}.jar";
      sha256 = "1pd7dsby3ksxk2ldqs3m9kqjwlpag3zhfs06v20nsy1n69md8bg6";
    };
  in ''
    mkdir -p $out
    cp ${jar} $out/${pname}.jar
  '';

  meta = with lib; {
    homepage = "https://github.com/retrooper/packetevents";
    description = "A cross-platform Bukkit and Velocity packet library.";
    maintainers = with maintainers; [zeratax];
  };
}
