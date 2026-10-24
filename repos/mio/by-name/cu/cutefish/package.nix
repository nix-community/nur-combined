# Not a desktop derivation. Nixpkgs does not ship Plasma or GNOME as one
# joined package; the module installs corePackages and optionalPackages.
# Top-level pkgs.cutefish-* are the individual components.
{
  cutefish-core,
  cutefish-compositor,
  cutefish-filemanager,
  cutefish-settings,
  cutefish-qt-plugins,
  cutefish-icons,
  cutefish-wallpapers,
  cutefish-terminal,
  cutefish-text-editor,
  cutefish-video-player,
  cutefish-calendar,
  cutefish-system-monitor,
  cutefish-calculator,
  xdg-desktop-portal-cutefish,
}:
import ./groups.nix {
  inherit
    cutefish-core
    cutefish-compositor
    cutefish-filemanager
    cutefish-settings
    cutefish-qt-plugins
    cutefish-icons
    cutefish-wallpapers
    cutefish-terminal
    cutefish-text-editor
    cutefish-video-player
    cutefish-calendar
    cutefish-system-monitor
    cutefish-calculator
    xdg-desktop-portal-cutefish
    ;
}
