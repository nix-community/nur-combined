{ ... }:
{
  sane.programs.gnome-calendar = {
    buildCost = 2;  # depends on webkitgtk_6_0 via evolution-data-server
    sandbox.mesaCacheDir = ".cache/gnome-calendar/mesa";  # TODO: is this the correct app-id?
    # gnome-calendar surely has data to persist, but i use it strictly to do date math, not track events.
    sandbox.whitelistWayland = true;
    sandbox.whitelistDbus.user = true;  #< TODO: reduce
    suggestedPrograms = [
      "evolution-data-server"  #< to access/persist calendar events
    ];
  };
}
