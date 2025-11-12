{
  lib,
  stdenv,
  fetchurl,
  server-type ? "paper",
}:
stdenv.mkDerivation rec {
  pname = "bluemap";
  version = "5.13";
  owner = "BlueMap-Minecraft";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://github.com/${owner}/BlueMap/releases/download/v${version}/BlueMap-${version}-${server-type}.jar";
      sha256 = "19sjxh2czaqbdw4n0s35k9m7xa8306g4d8c5py2dyr2r9wzhnhra";
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
