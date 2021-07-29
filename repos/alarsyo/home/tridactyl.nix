{ config, lib, ... }:
let
  cfg = config.my.home.tridactyl;
in
{
  options.my.home.tridactyl = with lib; {
    enable = (mkEnableOption "tridactyl code display tool") // { default = config.my.home.firefox.enable; };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
  };
}
