{ config, lib, pkgs, ... }:

with lib;
{
  config = mkIf config.programs.qt5ct.enable (with pkgs.libsForQt5; {
    nixpkgs.overlays = [ (import ../../overlays/qt5ct/default.nix) ];
    environment.variables.QT_PLUGIN_PATH = [ "${qqc2-desktop-style}/${qtbase.qtPluginPrefix}" ];
    environment.variables.QML2_IMPORT_PATH = [ "${qqc2-desktop-style}/${qtbase.qtQmlPrefix}" ];
  });
}
