{ 
  appimageTools
, lib
, fetchurl
, ...
}: let
  version = "1.5.12";
in appimageTools.wrapType2 {
  name = "obsidian-${version}";

  src = fetchurl {
    url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/Obsidian-${version}.AppImage";
    sha256 = "sha256-qmXZmSp7YPZ2k2+8gNYW9Fz5s0aMSrYHMBI7cn9M8u4=";
  };

  meta = with lib; {
    description = "Obsidian is the private and flexible writing app that adapts to the way you think.";
    homepage = "https://obsidian.md/";
    license = licenses.unfree;
    mainProgram = "obsidian";
    platforms = [ "x86_64-linux" ];
  };
}
