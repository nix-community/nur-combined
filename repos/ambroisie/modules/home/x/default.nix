{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.x;
in
{
  options.my.home.x = with lib; {
    enable = mkEnableOption "X server configuration";
  };

  config = lib.mkIf cfg.enable {
    xsession.enable = true;

    home.packages = with pkgs; [
      xsel
    ];
  };
}
