{ appimageTools, lib, fetchurl }:

appimageTools.wrapType2 rec {
  pname = "techmino";
  version = "0.17.6";

  src = fetchurl {
    url = "https://github.com/26F-Studio/Techmino/releases/download/v${version}/Techmino_Linux.AppImage";
    sha256 = "sha256-5DiY9JHfEt/JNFyqZeU8oDLBenHklcjoUT0XRCsnjtM=";
  };


  meta = with lib; {
    description = "Techmino";
    homepage = "https://github.com/26F-Studio/Techmino";
    license = licenses.lgpl3;
    platforms = [ "x86_64-linux" ];
  };
}
