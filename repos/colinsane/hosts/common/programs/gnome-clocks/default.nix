# TODO(2025-01-09): fix the 'alarm' component
# - it creates a desktop notification, but no sound, and permanently freezes the app
# TODO(2025-01-09): inhibit screen-off while focused (for stopwatch function)
{ ... }: {
  sane.programs.gnome-clocks = {
    buildCost = 1;
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus.user.own = [ "org.gnome.clocks" ];
    sandbox.whitelistSendNotifications = true;
    sandbox.whitelistWayland = true;
    sandbox.mesaCacheDir = ".cache/gnome-clocks/mesa";  # TODO: is this the correct app-id?
    gsettingsPersist = [ "org/gnome/clocks" ];
  };
}
