{ appimageTools, lib, fetchurl, ... }:
let
  version = "2.9.2-beta";
  # https://dl.snipaste.com/sha-1.txt
  sha1 = "ddde675a223ab2e905f39bb9aeb14601814fec39";
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
