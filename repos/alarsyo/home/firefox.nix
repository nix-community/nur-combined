{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.firefox;
in
{
  options.my.home.firefox = with lib; {
    enable = (mkEnableOption "firefox config") // { default = config.my.home.x.enable; };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox.override {
        cfg = {
          enableTridactylNative = true;
        };
      };
    };
  };
}
