{ config, lib, ... }:
let
  cfg = config.my.home.firefox.tridactyl;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
  };
}
