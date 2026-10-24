{
  lib,
  symlinkJoin,
  cutefish-core,
  cutefish-compositor,
  cutefish-filemanager,
  cutefish-icons,
  cutefish-wallpapers,
  cutefish-settings,
  cutefish-terminal,
  cutefish-text-editor,
  cutefish-video-player,
  cutefish-calendar,
  cutefish-system-monitor,
  cutefish-calculator,
  cutefish-qt-plugins,
  cutefish-dm,
  xdg-desktop-portal-cutefish,
}:

let
  cu = import ./mk.nix { inherit lib; };
in
symlinkJoin {
  name = "cutefish-${cu.version "2026-10-24"}";
  paths = [
    cutefish-core
    cutefish-compositor
    cutefish-filemanager
    cutefish-icons
    cutefish-wallpapers
    cutefish-settings
    cutefish-terminal
    cutefish-text-editor
    cutefish-video-player
    cutefish-calendar
    cutefish-system-monitor
    cutefish-calculator
    cutefish-qt-plugins
    cutefish-dm
    xdg-desktop-portal-cutefish
  ];

  passthru.providedSessions = cutefish-core.providedSessions;

  meta = {
    inherit (cu) homepage platforms;
    description = "Cutefish desktop: Wayland session, shell and applications";
    license = lib.licenses.bsd3;
  };
}
