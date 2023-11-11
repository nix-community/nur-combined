{ config, lib, ... }:
let
  cfg = config.my.home.jq;
in
{
  options.my.home.jq = with lib; {
    enable = my.mkDisableOption "jq configuration";
  };

  config.programs.jq = lib.mkIf cfg.enable {
    enable = true;
    colors = {
      null = "1;30";
      false = "0;37";
      true = "0;37";
      numbers = "0;37";
      strings = "0;32";
      arrays = "1;39";
      objects = "1;39";
    };
  };
}
