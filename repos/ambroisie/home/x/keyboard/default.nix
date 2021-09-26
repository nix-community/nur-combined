{ config, lib, ... }:
let
  cfg = config.my.home.x;
in
{
  config = lib.mkIf cfg.enable {
    home.keyboard = {
      layout = "fr";
      variant = "us";
    };
  };
}
