{ 
  appimageTools
, lib
, fetchurl
, ...
}: let
  version = "1.33.2";
in appimageTools.wrapType2 {
  name = "imhex-${version}";

  src = fetchurl {
    url = "https://github.com/WerWolv/ImHex/releases/download/v${version}/imhex-${version}-x86_64.AppImage";
    sha256 = "sha256-ULujG+Rv/HeAbSjrZNrF5tRF5IPGjvM1anNuLq6FZwM=";
  };

  meta = with lib; {
    description = "Virtual / remote desktop infrastructure for everyone! Open source TeamViewer / Citrix alternative";
    homepage = "https://rustdesk.com";
    license = licenses.agpl3Only;
    mainProgram = "imhex";
    platforms = [ "x86_64-linux" ];
  };
}
