{ config, lib, ... }:
let
  cfg = config.my.home.starship;
in
{
  options.my.home.starship.enable = lib.mkEnableOption "Starship.rs prompt";

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = false;
      };
    };
  };
}
