{ appimageTools, lib, fetchurl, ... }:
let
  version = "2.9.0-beta";
  # https://dl.snipaste.com/sha-1.txt
  sha1 = "00b81910bafb3d01c6f254cdbfa5acbe0ee4e550";
in
appimageTools.wrapType2 {
  inherit version;
  pname = "snipaste";

  src = fetchurl {
    url = "https://dl.snipaste.com/linux-beta";
    inherit sha1;
  };

  meta = with lib; {
    description = "Snipaste is a simple but powerful snipping tool, and also allows you to pin the screenshot back onto the screen.";
    homepage = "https://www.snipaste.com";
    license = licenses.unfree;
    mainProgram = "Snipaste";
    platforms = [ "x86_64-linux" ];
  };
}
