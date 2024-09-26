{
  lib,
  stdenv,
  fetchurl,
  server-type ? "paper",
}:
stdenv.mkDerivation rec {
  pname = "bluemap";
  version = "5.4";
  owner = "BlueMap-Minecraft";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://github.com/${owner}/BlueMap/releases/download/v${version}/${pname}-${version}-${server-type}.jar";
      sha256 = "134h7ssf9x6rxsdph451716a81i65rqmrc0ybxfmzfdsf3draaw7";
    };
  in ''
    mkdir -p $out
    cp ${jar} $out/${pname}.jar
  '';

  meta = with lib; {
    homepage = "https://bluemap.bluecolored.de/";
    description = "create 3D-maps of your Minecraft worlds and display them in your browser";
    maintainers = with maintainers; [zeratax];
  };
}
