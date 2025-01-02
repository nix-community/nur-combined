{ ... }: {
  sane.programs.gnome-clocks = {
    buildCost = 1;
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  #< required for DE notification when alarm rings
    sandbox.whitelistWayland = true;
    sandbox.mesaCacheDir = ".cache/gnome-clocks/mesa";  # TODO: is this the correct app-id?
    gsettingsPersist = [ "org/gnome/clocks" ];
  };
}
