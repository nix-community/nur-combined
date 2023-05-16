{ config, pkgs, lib, ... }: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.services.screenkey;
in {
  options = {
    services.screenkey = {
      enable = mkEnableOption "Screenkey";

      package = mkOption {
        description = "Screenkey package to be used";
        type = types.package;
        default = pkgs.screenkey;
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services.screenkey = {
      enable = true;
      path = with pkgs; [ cfg.package ];
      script = ''
        screenkey
      '';
    };
  };
}
