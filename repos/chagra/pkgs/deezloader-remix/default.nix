{ lib, appimageTools, fetchurl }:
let
  pname = "deezloader-remix";
  version = "4.3.0";
in appimageTools.wrapType2 rec {
  name = "deezloader-remix";
  src = fetchurl {
    url = "https://srv-file5.gofile.io/download/r4sZke/Deezloader_Remix_${version}-x86_64.AppImage";
    sha256 = "102ymmd9grycmiprfh4iz9j1kd9z1fbqi9i59vw2svdgfpa0p30q";
  };

  meta = with lib; {
    description = "Deezloader Remix is an improved version of Deezloader based on the Reborn branch";
    homepage = https://notabug.org/RemixDevs/DeezloaderRemix/;
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
  };
}
