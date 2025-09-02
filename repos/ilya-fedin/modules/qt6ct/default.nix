{ config, lib, pkgs, ... }:

with lib;
{
  config = mkIf (config.qt.enable && config.qt.platformTheme == "qt5ct") (with pkgs.kdePackages; {
    nixpkgs.overlays = [ (import ../../overlays/qt6ct) ];
    environment.variables.QT_PLUGIN_PATH = [ "${qqc2-desktop-style}/${qtbase.qtPluginPrefix}" ];
    environment.variables.QML2_IMPORT_PATH = [ "${qqc2-desktop-style}/${qtbase.qtQmlPrefix}" ];
  });
}
