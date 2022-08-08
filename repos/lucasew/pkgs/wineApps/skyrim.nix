{ appimage-wrap, makeDesktopItem, writeShellScript }:
let
  entry = writeShellScript "skyrim" ''
    ${appimage-wrap}/bin/appimage-wrap ~/Downloads/The_Elder_Scrolls_V_Skyrim_Special_Edition.AppImage
  '';
in makeDesktopItem {
  name = "tes-skyrim";
  exec = entry;
  desktopName = "The Elder Scrolls: Skyrim";
  categories = [ "Game" ];
}
