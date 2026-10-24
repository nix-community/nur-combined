# Package groups for the NixOS module. Plasma and GNOME do this in the module
# (requiredPackages / optionalPackages); LXQt exposes the same split as
# corePackages and optionalPackages. cutefish-dm is intentionally absent:
# the display manager is a separate package, the way SDDM and GDM are.
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
  ...
}:
{
  inherit
    cutefish-core
    xdg-desktop-portal-cutefish
    ;

  # Session, shell, settings, and artwork.
  corePackages = [
    cutefish-core
    cutefish-compositor
    cutefish-filemanager # paints the desktop icons
    cutefish-settings
    cutefish-qt-plugins
    cutefish-icons
    cutefish-wallpapers
  ];

  # Installed by default. Drop entries with environment.cutefish.excludePackages.
  optionalPackages = [
    cutefish-terminal
    cutefish-text-editor
    cutefish-video-player
    cutefish-calendar
    cutefish-system-monitor
    cutefish-calculator
  ];
}
