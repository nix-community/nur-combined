{ appimageTools, lib, fetchurl, ... }:
let
  version = "2.10";
  # https://dl.snipaste.com/sha-1.txt
  hash = "sha256-W0lTRcCn3YyUK5Hio7o74NP3zvHw9+iffwXC0AnFg0Q=";
in
appimageTools.wrapType2 {
  inherit version;
  pname = "snipaste";

  src = fetchurl {
    url = "https://bitbucket.org/liule/snipaste/downloads/Snipaste-${version}-x86_64.AppImage";
    inherit hash;
  };

  meta = with lib; {
    description = "Snipaste is a simple but powerful snipping tool, and also allows you to pin the screenshot back onto the screen.";
    homepage = "https://www.snipaste.com";
    license = licenses.unfree;
    mainProgram = "Snipaste";
    platforms = [ "x86_64-linux" ];
  };
}
