{ appimage-wrap, makeDesktopItem, writeShellScriptBin, buildEnv }:
let
  entry = writeShellScriptBin "skyrim" ''
    ${appimage-wrap}/bin/appimage-wrap ~/Downloads/The_Elder_Scrolls_V_Skyrim_Special_Edition.AppImage "$@"
  '';
  desktop = makeDesktopItem {
    name = "tes-skyrim";
    exec = "skyrim";
    desktopName = "The Elder Scrolls: Skyrim";
    categories = [ "Game" ];
  };
in buildEnv {
  name = "skyrim";
  paths = [
    entry
    desktop
  ];
}
