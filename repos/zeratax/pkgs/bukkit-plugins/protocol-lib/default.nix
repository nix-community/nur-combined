{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "protocol-lib";
  version = "5.4.0";
  owner = "dmulloy2";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://github.com/${owner}/ProtocolLib/releases/download/${version}/ProtocolLib.jar";
      sha256 = "1kxcbhgzn294dqyvb4m65kgka40vwq4d3i416082svrqnnwplbpf";
    };
  in ''
    mkdir -p $out
    cp ${jar} $out/${pname}.jar
  '';

  meta = with lib; {
    homepage = "https://github.com/dmulloy2/ProtocolLib";
    description = "Provides read and write access to the Minecraft protocol with Bukkit.";
    maintainers = with maintainers; [zeratax];
  };
}
