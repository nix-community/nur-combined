# soulseek filesharing GUI app
{ pkgs, ... }:
{
  sane.programs.nicotine-plus = {
    sandbox.method = "bwrap";
    sandbox.whitelistWayland = true;
    sandbox.net = "vpn";

    # ".config/nicotine": contains the config file, with plaintext creds.
    # TODO: define this as a secret instead of persisting it.
    persist.byStore.private = [ ".config/nicotine" ];
  };
}
