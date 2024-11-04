{ lib, appimageTools, fetchurl }:
let
  pname = "suyu";
  version = "0.0.3";

  src = fetchurl {
    url = "https://git.suyu.dev/suyu/suyu/releases/download/v${version}/Suyu-Linux_x86_64.AppImage";
    hash = "sha256-26sWhTvB6K1i/K3fmwYg5pDIUi+7xs3dz8yVj5q7H0c=";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  meta = with lib; {
    description = "Suyu was the continuation of the world's most popular, open-source Nintendo Switch emulator, yuzu, but is now something more.";
    homepage = "https://git.suyu.dev/suyu/suyu";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    hydraPlatforms = [ ];
    license = with licenses; [ gpl3Plus ];
  };
}
