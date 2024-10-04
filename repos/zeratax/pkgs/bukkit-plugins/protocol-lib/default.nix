{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "protocol-lib";
  version = "5.2.0";
  owner = "dmulloy2";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      # url = "https://github.com/${owner}/ProtocolLib/releases/download/${version}/ProtocolLib.jar";
      url = "https://ci.dmulloy2.net/job/ProtocolLib/lastSuccessfulBuild/artifact/build/libs/ProtocolLib.jar";
      sha256 = "05p09hcgm140h59kqcbzrh357vn70r7r1hagf9jzyc6z0s7va22a";
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
