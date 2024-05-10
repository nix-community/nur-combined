{ appimageTools, lib, fetchurl, ... }:
let
  version = "2.9.0-beta2";
  # https://dl.snipaste.com/sha-1.txt
  sha1 = "c9fb6901846a6e752e3697a45a6482523f3a83b8";
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
