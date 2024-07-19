# soulseek filesharing GUI app
# note that when you run this GUI, that seems to kick off the slskd daemon
{ pkgs, ... }:
{
  sane.programs.nicotine-plus = {
    sandbox.method = "bwrap";
    sandbox.whitelistDri = true;  #< required, else it fails to launch the gui
    sandbox.whitelistWayland = true;
    sandbox.net = "vpn";

    persist.byStore.private = [
      # ".config/nicotine": contains the config file, with plaintext creds.
      # TODO: define this as a secret instead of persisting it.
      ".config/nicotine"
    ];
    persist.byStore.plaintext = [
      ".local/share/nicotine/downloads"
    ];
  };
}
