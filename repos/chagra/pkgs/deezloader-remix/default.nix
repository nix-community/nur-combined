{ lib, appimageTools, fetchurl }:
let
  pname = "deezloader-remix";
  version = "4.3.0";
in appimageTools.wrapType2 rec {
  name = "deezloader-remix";
  src = fetchurl {
    url = "https://www.dropbox.com/s/vx39czo691ndtfr/Deezloader_Remix_${version}-x86_64.appimage?dl=1";
    sha256 = "0gvc62dvdr31ga7zdlad0xfxwjkqir8qc7l6h22lj2vkvgxmpnwc";
  };

  meta = with lib; {
    description = "Deezloader Remix is an improved version of Deezloader based on the Reborn branch";
    homepage = https://notabug.org/RemixDevs/DeezloaderRemix/;
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
  };
}
