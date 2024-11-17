{ ... }: {
  sane.programs.gnome-clocks = {
    buildCost = 1;
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  #< required for DE notification when alarm rings
    sandbox.whitelistWayland = true;
    gsettingsPersist = [ "org/gnome/clocks" ];
  };
}
