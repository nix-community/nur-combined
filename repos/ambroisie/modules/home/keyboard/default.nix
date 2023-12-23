{ config, lib, ... }:
let
  cfg = config.my.home.keyboard;
in
{
  options.my.home.keyboard = with lib; {
    enable = my.mkDisableOption "keyboard configuration";
  };

  config = lib.mkIf cfg.enable {
    home.keyboard = {
      layout = "fr";
      variant = "us";
    };
  };
}
