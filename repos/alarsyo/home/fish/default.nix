{ config, lib, ... }:
let
  cfg = config.my.home.fish;
in
{
  options.my.home.fish.enable = (lib.mkEnableOption "Fish shell") // { default = true; };

  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = true;
    };

    xdg.configFile."fish/functions" = { source = ./. + "/functions"; };
  };
}
