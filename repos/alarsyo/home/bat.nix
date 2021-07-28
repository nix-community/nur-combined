{ config, lib, ... }:
let
  cfg = config.my.home.bat;
  batTheme = config.my.theme.batTheme;
in
{
  options.my.home.bat = with lib; {
    enable = (mkEnableOption "bat code display tool") // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    programs.bat = {
      enable = true;

      config = {
        theme = batTheme.name;
      };
    };
  };
}
