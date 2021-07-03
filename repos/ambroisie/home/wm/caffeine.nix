{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.wm.caffeine;
in
{
  config = lib.mkIf cfg.enable {
    services.caffeine = {
      enable = true;
    };
  };
}
