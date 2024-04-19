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
    description = "A Hex Editor for Reverse Engineers, Programmers and people who value their retinas when working at 3 AM.";
    homepage = "https://imhex.werwolv.net/";
    license = licenses.gpl2Only;
    mainProgram = "imhex";
    platforms = [ "x86_64-linux" ];
  };
}
