{ appimageTools, lib, fetchurl, ... }:
let
  version = "2.8.9-beta";
  # https://dl.snipaste.com/sha-1.txt
  sha1 = "f76ec744514b41c298501a3db3b90f24d75faada";
in
appimageTools.wrapType2 {
  inherit version;
  pname = "snipaste";
  name = "snipaste";

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
