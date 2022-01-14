{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
  ;

  cfg = config.my.home.fish;
in
{
  options.my.home.fish.enable = (mkEnableOption "Fish shell") // { default = true; };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
    };

    xdg.configFile."fish/functions" = { source = ./. + "/functions"; };
  };
}
