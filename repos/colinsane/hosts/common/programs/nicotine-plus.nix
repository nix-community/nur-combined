# soulseek filesharing GUI app
{ ... }:
{
  sane.programs.nicotine-plus = {
    net = "vpn";
    # ".config/nicotine": contains the config file, with plaintext creds.
    # TODO: define this as a secret instead of persisting it.
    persist.byStore.private = [ ".config/nicotine" ];
  };
}
